variable "name" {
  type        = string
  description = "Name prefix"
}

variable "aws_region" {
  type        = string
  description = "AWS region (for logs config)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS tasks (public subnets in this low-cost setup)"
}

variable "ecs_sg_id" {
  type        = string
  description = "Security group for ECS tasks"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN"
}

variable "repository_url" {
  type        = string
  description = "ECR repo URL, e.g. 123.dkr.ecr.region.amazonaws.com/umami"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy"
}

variable "app_port" {
  type        = number
  description = "Container port the app listens on (e.g. 3000)"
}

variable "database_url" {
  type        = string
  sensitive   = true
  description = "DATABASE_URL for Umami"
}

variable "app_secret" {
  type        = string
  sensitive   = true
  description = "APP_SECRET for Umami"
}

