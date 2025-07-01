output "alb_dns_name" {
  value       = aws_alb.web_server_alb.dns_name
  description = "DNS name of the load balancer"
}

output "asg_name" {
  value = aws_autoscaling_group.web_server_asg.name
  description = "The name of the autoscaling group"
}