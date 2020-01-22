resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.cname}.${var.root_zone}"
  acl    = "public-read"
  website {
    index_document = var.index_page
    error_document = var.error_page
  }

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::${var.cname}.${var.root_zone}/*"
      ]
    }
  ]
}
POLICY
  tags   = "${merge(map("Environment", format("%s", var.environment)), map("DeployedBy", "terraform"), var.custom_tags)}"
}


resource "aws_cloudfront_distribution" "cdn" {
  depends_on = ["aws_s3_bucket.website_bucket"]

  origin {
    // We need to set up a "custom" origin because otherwise CloudFront won't
    // redirect traffic from the root domain to the www domain, that is from
    // runatlantis.io to www.runatlantis.io.
    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    // This can be any name to identify this origin.
    origin_id = "S3-${var.cname}.${var.root_zone}"
  }

  aliases = flatten([
    "${var.cname}.${var.root_zone}",
    #var.additional_vhosts,
  ])

  default_root_object = var.index_page
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"

  custom_error_response {
    error_caching_min_ttl = "300"
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.error_page}"
  }

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST",
      "PUT",
    ]

    cached_methods = ["GET", "HEAD"]
    compress       = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    default_ttl            = 86400
    max_ttl                = 31536000
    min_ttl                = 0
    target_origin_id       = "S3-${var.cname}.${var.root_zone}"
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

  tags = "${merge(map("Environment", format("%s", var.environment)), map("DeployedBy", "terraform"), var.custom_tags)}"

}

data "aws_route53_zone" "main" {
  name         = var.root_zone
  private_zone = false
}

resource "aws_route53_record" "DnsRecord" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.cname}.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = var.eval_health_check
  }
}


# Certificate creation and validation
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.cname}.${var.root_zone}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = data.aws_route53_zone.main.id
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
