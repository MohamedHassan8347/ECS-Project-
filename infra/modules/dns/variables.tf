variable "domain_name" {
  type        = string
  description = "Base domain, e.g. mhecsproject.com"
}

variable "subdomain" {
  type        = string
  description = "Subdomain label, e.g. tm"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB hosted zone ID"
}

