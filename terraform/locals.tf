locals {
  env              = lower(var.environment)
  full_domain_name = var.subdomain_name == "" ? var.domain_name : "${var.subdomain_name}.${var.domain_name}"
}