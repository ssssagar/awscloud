resource "aws_cloudfront_distribution" "custom_distribution" {
  comment = "CloudFront CDN with custom origin, it takes request from website and add's custom analytic's script in client response using lambda@edge function and returns response to client"
  aliases = ["subdomain.domain.com", "wildcard.domain.com"]

  enabled = true
  price_class = "PriceClass_200"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "custom.domain.com.id"

    viewer_protocol_policy = "redirect-to-https"
    #Using the CachingDisabled managed policy ID:
    cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    lambda_function_association {
      event_type   = "viewer-response"
      lambda_arn   = aws_lambda_function.viewer_response_lambda.qualified_arn
      include_body = false
    }
    compress = true
  }

  origin {
    domain_name = "custom.domain.com"
    origin_id   = "custom.domain.com.id"
    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  tags = {
    Name        = "lambda_edge_cloudfront_terraform"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "KY", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:12345678910:certificate/er612862-04a8-48f2-920k-askdjkagdj9g"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }
}


output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.custom_distribution.id
}