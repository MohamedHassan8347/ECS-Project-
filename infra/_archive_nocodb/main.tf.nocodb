########################################################
# Providers
########################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "eu-north-1"
}

########################################################
# Variables (set values in terraform.tfvars)
########################################################
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "domain_name" {}      # your domain, e.g., mhecsproject.com
variable "docker_image_uri" {} # ECR image URI, e.g., 171916339633.dkr.ecr.eu-north-1.amazonaws.com/nocodb-app:latest
variable "db_username" {}
variable "db_password" {}
variable "acm_certificate_arn" {} # ARN of your ACM certificate

variable "hosted_zone_id" {
  description = "The Route53 hosted zone ID for your domain"
  type        = string
}

########################################################
# ECS Cluster
########################################################
resource "aws_ecs_cluster" "nocodb_cluster" {
  name = "nocodb-cluster"
}

########################################################
# Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
 
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Top-level security group rule for ECS -> RDS access
resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id      # RDS SG
  source_security_group_id = aws_security_group.ecs_sg.id      # ECS SG
}


########################################################
# RDS Postgres
########################################################
resource "aws_db_subnet_group" "nocodb_db_subnet" {
  name       = "nocodb-db-subnet"
  description = "Subnet group for NocoDB RDS instance"

subnet_ids = [
    "subnet-0d4cd7c28e8d16639", # private-subnet-a
    "subnet-0dded94a9325b713b", # private-subnet-b
    "subnet-01fe1c4998da027bf"  # private-subnet-3
  ]
  tags = {
    Name = "nocodb-db-subnet"
  }
}

resource "aws_db_instance" "nocodb_db" {
  identifier             = "nocodb-db"
  engine                 = "postgres"
  engine_version         = "15.14"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 20
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.nocodb_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

########################################################
# Application Load Balancer
########################################################
# ALB Resource
resource "aws_lb" "nocodb_alb" {
  name               = "nocodb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "nocodb-alb"
  }
}

# Target Group for ECS Service
resource "aws_lb_target_group" "nocodb_tg" {
  name     = "nocodb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "nocodb-tg"
  }
}

# HTTPS Listener (Port 443)
resource "aws_lb_listener" "nocodb_https_listener" {
  load_balancer_arn = aws_lb.nocodb_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # 🔹 Replace this ARN with your VALID ACM certificate ARN
  certificate_arn   =  "arn:aws:acm:eu-north-1:171916339633:certificate/7c1ab6d2-99d9-4e07-9509-e529a4ca6164"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nocodb_tg.arn
  }
}

# HTTP Listener (Port 80) — Redirect to HTTPS
resource "aws_lb_listener" "nocodb_http_redirect" {
  load_balancer_arn = aws_lb.nocodb_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
 

########################################################
# ECS Task Definition
########################################################
# 1️⃣ IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# 2️⃣ Attach the AWS-managed ECS execution policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 3️⃣ ECS Task Definition
resource "aws_ecs_task_definition" "nocodb_task" {
  family                   = "nocodb-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn  # reference the role

container_definitions = jsonencode([
  {
    name      = "nocodb-app"
    image     = var.docker_image_uri
    essential = true
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      }
    ]
    command = ["pnpm", "--filter=nocodb", "run", "start"]
    environment = [
      {
        name  = "DB_HOST"
        value = var.db_host
      },
      {
        name  = "DB_USER"
        value = var.db_user
      },
      {
        name  = "DB_PASS"
        value = var.db_pass
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/nocodb-service"
        "awslogs-region"        = "eu-north-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }
])
}

########################################################
# ECS Service
########################################################
resource "aws_ecs_service" "nocodb_service" {
  name            = "nocodb-service"
  cluster         = aws_ecs_cluster.nocodb_cluster.id
  task_definition = aws_ecs_task_definition.nocodb_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nocodb_tg.arn
    container_name   = "nocodb-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.nocodb_https_listener]
}

########################################################
# Route53 Record
########################################################
resource "aws_route53_record" "nocodb_record" {
  zone_id = var.hosted_zone_id
  name    = "tm.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nocodb_alb.dns_name
    zone_id                = aws_lb.nocodb_alb.zone_id
    evaluate_target_health = true
  }
}

