locals {
  env              = lower(var.environment)
  full_domain_name = var.subdomain_name == "" ? var.domain_name : "${var.subdomain_name}.${var.domain_name}"

  client_log_groups = "/ecs/servicios-cires-client-${local.env}"
  server_log_groups = "/ecs/servicios-cires-server-${local.env}"
}