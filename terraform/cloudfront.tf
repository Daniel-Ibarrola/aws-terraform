resource "aws_cloudfront_distribution" "servicios_cires_alb_distribution" {
  enabled     = true
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_alb.servicios_cires_alb.dns_name
    origin_id   = "servicios-cires-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "servicios-cires-alb-origin"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:668144156539:certificate/16fbad71-3ec4-4104-b71a-68021c193ef0"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Servicios Cires CloudFront Distribution"
    Env  = local.env
  }
}