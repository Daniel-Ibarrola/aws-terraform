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

data "aws_route_tables" "ats_private_rts" {
  vpc_id = data.aws_vpc.target_vpc.id
  filter {
    name   = "tag:Name"
    values = ["private-route-table"]
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

resource "aws_ecs_cluster" "ats_cluster" {
  name = "ats-client-cluster-qa"
  tags = {
    Name        = "ATS Client Cluster QA"
    Environment = var.environment
  }
}

# Allows ECS agent to pull ECR images
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ats-client-ecs-task-execution-role-qa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "ATS Client ECS Task Execution Role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ats_client_task_sg" {
  name        = "ats-client-task-sg-qa"
  description = "Allow traffic to ATS Client tasks from ALB and allow outbound"
  vpc_id      = data.aws_vpc.target_vpc.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ats_client_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ATS Client Task SG QA"
    Environment = var.environment
  }
}


resource "aws_ecs_task_definition" "ats_client_task_def" {
  family                   = "ats-client-app-qa"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # Role for pulling images/logs

  # Optional: Define a task role if your application code needs AWS permissions
  # task_role_arn            = aws_iam_role.app_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.app_image_uri
      cpu       = var.fargate_cpu
      memory    = var.fargate_memory
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      # Add environment variables if needed by your app
      # environment = [
      #   { name = "BACKEND_API_URL", value = "http://internal-backend-dns-or-ip/api" },
      #   { name = "NODE_ENV", value = "production" }
      # ]
      # Add secrets from Secrets Manager or Parameter Store if needed
      # secrets = [
      #   { name = "DATABASE_PASSWORD", valueFrom = "arn:aws:secretsmanager:..." }
      # ]
    }
  ])

  tags = {
    Name        = "ATS Client Task Definition"
    Environment = var.environment
  }
}


resource "aws_ecs_service" "ats_client_service" {
  name            = "ats-client-service-qa"
  cluster         = aws_ecs_cluster.ats_cluster.id
  task_definition = aws_ecs_task_definition.ats_client_task_def.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.ats_private_subnets.ids
    security_groups  = [aws_security_group.ats_client_task_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ats_client_alb_tg.arn
    container_name   = var.container_name
    container_port   = var.app_port
  }

  depends_on = [
    aws_lb_listener.ecs_alb_listener,
    null_resource.validate_subnets_found
  ]

  # Optional: Wait for service stability on create/update
  # wait_for_steady_state = true

  tags = {
    Name        = "ATS Client Service QA"
    Environment = var.environment
  }
}

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

  # Typically, endpoints don't need egress rules, but allow all if needed for specific scenarios
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