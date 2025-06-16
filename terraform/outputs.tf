output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.servicios_cires_alb.dns_name
}
