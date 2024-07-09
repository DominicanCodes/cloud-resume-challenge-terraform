# display website URL
output "website_url" {
  description = "URL of the static website"
  value       = aws_s3_bucket_website_configuration.hosting_bucket_web_config.website_endpoint

}
