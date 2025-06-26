resource "aws_cloudwatch_log_group" "servicios_cires_client_logs" {
  name              = local.client_log_groups
  retention_in_days = 30

  tags = {
    Name = "Servicios Cires Client Logs"
    Env  = local.env
  }
}

resource "aws_cloudwatch_log_group" "servicios_cires_server_logs" {
  name              = local.server_log_groups
  retention_in_days = 30

  tags = {
    Name = "Servicios Cires Server Logs"
    Env  = local.env
  }
}
