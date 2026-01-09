variable "domain_name" {
  type        = string
  description = "Base domain, e.g. example.com"
}

variable "subdomain" {
  type        = string
  description = "Subdomain label, e.g. tm or umami"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for the domain"
}



