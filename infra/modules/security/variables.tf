variable "name" {
  description = "Name prefix for security resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "app_port" {
  description = "App port exposed by the ECS task (e.g. 3000)"
  type        = number
}

