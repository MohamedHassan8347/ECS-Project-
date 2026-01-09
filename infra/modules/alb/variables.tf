variable "name" {
  type        = string
  description = "Name prefix for ALB resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the ALB (public subnets)"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "app_port" {
  type        = number
  description = "Target group port (app port)"
}

variable "health_check_path" {
  type        = string
  description = "Health check path"
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}


