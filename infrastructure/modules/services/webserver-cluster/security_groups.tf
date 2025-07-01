resource "aws_security_group" "load_balancer_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Allow traffic from anywhere in port 80"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_inbound" {
  security_group_id = aws_security_group.load_balancer_sg.id

  from_port   = local.http_port
  to_port     = local.http_port
  ip_protocol = local.tcp_protocol
  cidr_ipv4   = local.all_ips
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.load_balancer_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  ip_protocol = local.any_protocol
  cidr_ipv4   = local.all_ips
}

resource "aws_security_group" "web_server_sg" {
  name        = "${var.cluster_name}-webserver-sg"
  description = "Allow traffic from ALB security group"


  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_server_port_inbound" {
  security_group_id = aws_security_group.web_server_sg.id

  from_port       = var.server_port
  to_port         = var.server_port
  ip_protocol     = local.tcp_protocol
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.web_server_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  ip_protocol = local.any_protocol
  cidr_ipv4   = local.all_ips
}