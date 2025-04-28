terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["Applicant Tracking System qa VPC"]
  }
}

data "aws_subnets" "ats_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.target_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["ats-private-subnet-*"]
  }
}

data "aws_subnets" "ats_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.target_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["ats-public-subnet-*"]
  }
}

# --- Check if subnets were found ---
# This will cause Terraform plan/apply to fail if no matching subnets are found
resource "null_resource" "validate_subnets_found" {
  triggers = {
    private_subnet_count = length(data.aws_subnets.ats_private_subnets.ids) > 0 ? "valid" : "error: no private subnets found matching pattern ats-private-subnet_*"
    public_subnet_count  = length(data.aws_subnets.ats_public_subnets.ids) > 0 ? "valid" : "error: no public subnets found matching pattern ats-public-subnet*"
  }

  # Use lifecycle rule to ensure this check passes before proceeding
  lifecycle {
    postcondition {
      condition     = self.triggers.private_subnet_count == "valid"
      error_message = self.triggers.private_subnet_count
    }
    postcondition {
      condition     = self.triggers.public_subnet_count == "valid"
      error_message = self.triggers.public_subnet_count
    }
  }
}


resource "aws_security_group" "ats_client_alb_sg" {
  name        = "ATS Client ALB Security Group"
  vpc_id      = data.aws_vpc.target_vpc.id
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
}

resource "aws_alb" "ats_client_alb" {
  name               = "ats-client-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = data.aws_subnets.ats_public_subnets.ids
  security_groups    = [aws_security_group.ats_client_alb_sg.id]

  tags = {
    Name = "ATS Client ALB"
  }
}

resource "aws_lb_target_group" "ats_client_alb_tg" {
  name        = "ats-client-alb-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.target_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_alb.ats_client_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ats_client_alb_tg.arn
  }
}