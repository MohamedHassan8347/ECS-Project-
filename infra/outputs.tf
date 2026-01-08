output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "app_url" {
  value = "https://${var.subdomain}.${var.domain_name}"
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

