data "aws_route53_zone" "primary" {
  name         = trimsuffix(var.domain_name, ".") # Ensure no trailing dot
  private_zone = false
}

resource "aws_route53_record" "alias_record_to_cloudfront_distribution" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.full_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.servicios_cires_alb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.servicios_cires_alb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}