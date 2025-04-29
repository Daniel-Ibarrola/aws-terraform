resource "aws_acm_certificate" "app_cert" {
  domain_name       = local.full_domain_name
  validation_method = "DNS"

  tags = {
    Name        = "${local.full_domain_name} Certificate"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true # Allows replacing certificate easily later
  }
}

# Creates the CNAME record required by ACM to prove domain ownership
resource "aws_route53_record" "cert_validation" {
  # Allow multiple validation records if subject_alternative_names are used
  for_each = {
    for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true # Useful if validation needs retrying
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}


# TODO: move certificate creation and validation out. It can take too long to be run in a bitbucket pipeline

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.app_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.full_domain_name
  type    = "A"

  alias {
    name                   = aws_alb.ats_client_alb.dns_name
    zone_id                = aws_alb.ats_client_alb.zone_id
    evaluate_target_health = true
  }
}