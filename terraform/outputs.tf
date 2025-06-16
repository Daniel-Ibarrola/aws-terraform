output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.servicios_cires_alb.dns_name
}

output "route53_record_name" {
  description = "Name of the route 53 record"
  value = aws_route53_record.alias_record_to_cloudfront_distribution.name
}