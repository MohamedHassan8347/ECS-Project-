############################################
# Global
############################################

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

############################################
# Networking
############################################

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (for ALB & ECS)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (for RDS)"
  type        = list(string)
}

############################################
# Application
############################################

variable "app_port" {
  description = "Port the application listens on"
  type        = number
}

variable "image_tag" {
  description = "Docker image tag (commit SHA)"
  type        = string
}

variable "app_secret" {
  description = "Application secret"
  type        = string
  sensitive   = true
}

############################################
# Database
############################################

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

############################################
# DNS / TLS
############################################

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain (e.g. tm)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM cert ARN in eu-north-1 for tm.<domain>"
  type        = string
}

