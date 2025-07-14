resource "aws_launch_template" "web_server_launch_template" {
  image_id      = var.ami
  instance_type = var.instance_type
  name          = "${var.cluster_name}-launch-template"

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = base64encode(templatefile(
    "${path.module}/user-data/user-data.sh.tftpl",
    {
      db_address = data.terraform_remote_state.db.outputs.address
      db_port    = data.terraform_remote_state.db.outputs.port
      server_text = var.server_text
    }
  ))

}

resource "aws_autoscaling_group" "web_server_asg" {
  max_size = var.max_size
  min_size = var.min_size
  name     = "${var.cluster_name}-autoscaling-group"

  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_alb_target_group.web_server_tg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.web_server_launch_template.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.cluster_name
  }

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_alb" "web_server_alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.load_balancer_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.web_server_alb.arn
  port              = local.http_port
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
  name     = "${var.cluster_name}-web-server-tg"
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

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
}