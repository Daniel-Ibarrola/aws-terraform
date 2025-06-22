resource "aws_launch_template" "web_server_launch_template" {
  image_id      = "ami-06971c49acd687c30"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  )
}

resource "aws_autoscaling_group" "web_server_asg" {
  max_size = 10
  min_size = 2

  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_alb_target_group.web_server_tg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.web_server_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "webserver"
  }
}

resource "aws_alb" "web_server_alb" {
  name               = "webserver-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.load_balancer_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.web_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}

resource "aws_alb_target_group" "web_server_tg" {
  name     = "web-server-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener_rule" "forward_to_webserver_tg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web_server_tg.arn
  }
}
