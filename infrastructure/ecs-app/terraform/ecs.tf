resource "aws_service_discovery_http_namespace" "service_connect_namespace" {
  name        = "servicios-cires-namespace-${local.env}"
  description = "Service Connect namespace for Servicios Cires microservices"

  tags = {
    Name = "Servicios Cires Service Connect Namespace"
    Env  = local.env
  }
}

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
      name  = var.client_container_name
      image = var.client_app_image_uri
      image_version = timestamp()
      cpu       = var.fargate_cpu
      memory    = var.fargate_memory
      essential = true
      portMappings = [
        {
          containerPort = var.client_app_port
          hostPort      = var.client_app_port
          protocol      = "tcp"
          name          = "client-web"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.client_log_groups
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

resource "aws_ecs_task_definition" "servicios_cires_server_task_def" {
  family                   = "servicios_cires-server-app-${local.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.server_container_name
      image = var.server_app_image_uri
      # image_version = timestamp()
      cpu       = var.fargate_cpu
      memory    = var.fargate_memory
      essential = true
      portMappings = [
        {
          containerPort = var.server_app_port
          hostPort      = var.server_app_port
          protocol      = "tcp"
          name          = "server-api-port"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.server_log_groups
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "Servicios Cires Server Task Definition"
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
    container_name   = var.client_container_name
    container_port   = var.client_app_port
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect_namespace.arn
  }

  tags = {
    Name = "Servicios Cires Client Service"
    Env  = local.env
  }
}

resource "aws_ecs_service" "servicios_cires_server_service" {
  name            = "servicios_cires-server-service-${local.env}"
  cluster         = aws_ecs_cluster.servicios_cires_cluster.id
  task_definition = aws_ecs_task_definition.servicios_cires_server_task_def.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in aws_subnet.servicios-cires-private-subnet : subnet.id]
    security_groups  = [aws_security_group.servicios_cires_server_service_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.service_connect_namespace.arn

    service {
      port_name      = "server-api-port"
      discovery_name = "server-api"
      client_alias {
        port     = var.server_app_port
        # DNS name must include namespace
        dns_name = "server-api.${aws_service_discovery_http_namespace.service_connect_namespace.name}"
      }
    }
  }

  tags = {
    Name = "Servicios Cires Server Service"
    Env  = local.env
  }
}