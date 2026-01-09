output "certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "fqdn" {
  value = "${var.subdomain}.${var.domain_name}"
}

