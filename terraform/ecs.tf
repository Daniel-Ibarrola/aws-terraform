resource "aws_ecs_cluster" "servicios_cires_cluster" {
  name = "servicios-cires-cluster-${local.env}"
  tags = {
    Name = "Servicios Cires Client Cluster"
    Env  = local.env
  }
}

resource "aws_ecs_task_definition" "servicios_cires_client_task_def" {
  family                   = "servicios_cires-client-app-${local.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name          = var.container_name
      image         = var.app_image_uri
      # image_version = timestamp()
      cpu           = var.fargate_cpu
      memory        = var.fargate_memory
      essential     = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/servicios-cires-client-${local.env}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "Servicios Cires Client Task Definition"
    Env  = local.env
  }
}

resource "aws_ecs_service" "servicios_cires_client_service" {
  name            = "servicios_cires-client-service-${local.env}"
  cluster         = aws_ecs_cluster.servicios_cires_cluster.id
  task_definition = aws_ecs_task_definition.servicios_cires_client_task_def.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in aws_subnet.servicios-cires-private-subnet : subnet.id]
    security_groups  = [aws_security_group.servicios_cires_client_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.servicios_cires_tg.arn
    container_name   = var.container_name
    container_port   = var.app_port
  }

  tags = {
    Name = "Servicios Cires Client Service"
    Env  = local.env
  }
}
