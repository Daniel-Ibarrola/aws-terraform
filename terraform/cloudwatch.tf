resource "aws_cloudwatch_log_group" "servicios_cires_client_logs" {
  name              = "/ecs/servicios-cires-client-${local.env}"
  retention_in_days = 30

  tags = {
    Name = "Servicios Cires Client Logs"
    Env  = local.env
  }
}
