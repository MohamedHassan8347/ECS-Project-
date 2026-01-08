module "network" {
  source = "./modules/network"

  name     = var.project_name
  vpc_cidr = "10.0.0.0/16"
}

module "security" {
  source = "./modules/security"

  name     = var.project_name
  vpc_id   = module.network.vpc_id
  app_port = var.app_port
}

module "ecr" {
  source = "./modules/ecr"
  name   = var.project_name
}

module "rds" {
  source = "./modules/rds"

  name        = var.project_name
  subnet_ids  = module.network.public_subnet_ids
  db_sg_id    = module.security.db_sg_id
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

locals {
  # urlencode() makes special chars safe in URLs (e.g. !, @, :)
  database_url = "postgresql://${var.db_username}:${urlencode(var.db_password)}@${module.rds.endpoint}:${module.rds.port}/${var.db_name}?sslmode=require"
}

module "alb" {
  source = "./modules/alb"

  name              = var.project_name
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  app_port          = var.app_port
  health_check_path = "/"
  certificate_arn   = module.dns_acm.certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  name             = var.project_name
  aws_region       = var.aws_region
  subnet_ids       = module.network.public_subnet_ids
  ecs_sg_id        = module.security.ecs_sg_id
  target_group_arn = module.alb.target_group_arn

  repository_url = module.ecr.repository_url
  image_tag      = var.image_tag

  app_port     = var.app_port
  database_url = local.database_url
  app_secret   = var.app_secret
}

module "dns_acm" {
  source = "./modules/dns_acm"

  domain_name  = var.domain_name
  subdomain    = var.subdomain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

