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

  tags = {
    Name        = "ATS Client Service QA"
    Environment = var.environment
  }
}
