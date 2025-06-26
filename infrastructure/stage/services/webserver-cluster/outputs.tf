output "alb_dns_name" {
  value       = aws_alb.web_server_alb.dns_name
  description = "DNS name of the load balancer"
}