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

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

############################################
# Networking (Custom VPC created by Terraform)
############################################

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (for ALB & ECS in this low-cost setup)"
  type        = list(string)

  # Two subnets across two AZs is a good baseline
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (for RDS)"
  type        = list(string)

  default = ["10.0.101.0/24", "10.0.102.0/24"]
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



