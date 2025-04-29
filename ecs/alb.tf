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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ATS Client ALB Security Group"
    Environment = var.environment
  }
}

resource "aws_alb" "ats_client_alb" {
  name               = "ats-client-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = data.aws_subnets.ats_public_subnets.ids
  security_groups    = [aws_security_group.ats_client_alb_sg.id]

  tags = {
    Name        = "ATS Client ALB"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "ats_client_alb_tg" {
  name        = "ats-client-alb-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.target_vpc.id

  health_check {
    enabled  = true
    interval = 30
    # TODO: custom health check path
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ecs_alb_listener_https" {
  load_balancer_arn = aws_alb.ats_client_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ats_client_alb_tg.arn
  }

  depends_on = [aws_acm_certificate_validation.cert]
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_alb.ats_client_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"  # Keep the original host
      path        = "/#{path}" # Keep the original path
      query       = "#{query}" # Keep the original query string
    }
  }
}