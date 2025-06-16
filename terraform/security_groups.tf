resource "aws_security_group" "servicios_cires_alb_sg" {
  name        = "Servicios Cires Client ALB Security Group"
  vpc_id      = aws_vpc.servicios_cires_vpc.id
  description = "Security group for load balancer to allow HTTP traffic from anywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Servicios Cires ALB Security Group"
    Env  = local.env
  }
}

resource "aws_security_group" "servicios_cires_client_service_sg" {
  name        = "servicios-cires-client-task-sg-${local.env}"
  description = "Allow traffic to Servicios Cires Client tasks from ALB and allow outbound"
  vpc_id      = aws_vpc.servicios_cires_vpc.id

  ingress {
    description     = "Allow traffic from ALB security group"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.servicios_cires_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Servicios Cires Client Task SG"
    Env  = local.env
  }
}

# This SG controls traffic to the endpoint ENIs from within your VPC
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg-qa"
  description = "Allow traffic from within VPC to VPC Endpoints"
  vpc_id      = aws_vpc.servicios_cires_vpc.id

  ingress {
    description     = "Allow HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.servicios_cires_client_service_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "VPC Endpoint SG"
    Env = local.env
  }
}