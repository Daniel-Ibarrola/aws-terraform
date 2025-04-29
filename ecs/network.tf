# This SG controls traffic *to* the endpoint ENIs from within your VPC
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg-qa"
  description = "Allow traffic from within VPC to VPC Endpoints"
  vpc_id      = data.aws_vpc.target_vpc.id

  ingress {
    description     = "Allow HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ats_client_task_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "VPC Endpoint SG"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = data.aws_vpc.target_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = data.aws_subnets.ats_private_subnets.ids
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "ECR API Endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = data.aws_vpc.target_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = data.aws_subnets.ats_private_subnets.ids
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name        = "ECR DKR Endpoint"
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = data.aws_vpc.target_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = data.aws_route_tables.ats_private_rts.ids

  tags = {
    Name = "S3 Gateway Endpoint QA"
  }
}