output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.ats_client_alb.dns_name
}
