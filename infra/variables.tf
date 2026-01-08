variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Prefix for resource names/tags"
  type        = string
  default     = "umami"
}

variable "domain_name" {
  description = "Root domain managed in Route 53 (e.g., mhecsproject.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the app (e.g., tm)"
  type        = string
  default     = "tm"
}

variable "app_port" {
  description = "Container port Umami listens on"
  type        = number
  default     = 3000
}

variable "image_tag" {
  description = "Docker image tag (usually commit SHA) pushed to ECR"
  type        = string
}

variable "db_name" {
  description = "Postgres database name"
  type        = string
  default     = "umami"
}

variable "db_username" {
  description = "Postgres username"
  type        = string
  default     = "umami"
}

variable "db_password" {
  description = "Postgres password"
  type        = string
  sensitive   = true
}

variable "app_secret" {
  description = "Umami APP_SECRET"
  type        = string
  sensitive   = true
}

