output "alb_dns_name" {
  value       = aws_alb.web_server_alb.dns_name
  description = "DNS name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.web_server_asg.name
  description = "The name of the autoscaling group"
}

output "alb_sg_id" {
  value = aws_security_group.load_balancer_sg.id
  description = "The id of the ALB security group"
}

output "webserver_sg_ig" {
  value = aws_security_group.web_server_sg.id
  description = "The id of the webserver cluster security group"
}