resource "aws_alb" "servicios_cires_alb" {
  name               = "servicios-cires-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [for subnet in aws_subnet.servicios-cires-public-subnet : subnet.id]
  security_groups    = [aws_security_group.servicios_cires_alb_sg.id]

  tags = {
    Name        = "Servicios Cires Client ALB"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "servicios_cires_tg" {
  name        = "servicios-cires-tg"
  port        = var.client_app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.servicios_cires_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_alb.servicios_cires_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.servicios_cires_tg.arn
  }
}