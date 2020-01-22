output "url_host" {
  value       = "https://${aws_route53_record.DnsRecord.fqdn}/"
  description = "URL of the website"
}

output "fqdn" {
  value = aws_route53_record.DnsRecord.fqdn
}

output "cdn_distribution_id" {
  value       = "${aws_cloudfront_distribution.cdn.id}"
  description = "CloudFront distribution ID"
}

output "s3_bucket" {
  value       = "${aws_s3_bucket.website_bucket.id}"
  description = "s3 bucket ID"
}
