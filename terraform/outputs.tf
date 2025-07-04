output "s3-bucket-website-endpoint" {
  value = aws_s3_bucket_website_configuration.s3_bucket_website_configuration.website_endpoint
  description = "S3 Bucket Website Endpoint"
}

output "api-gateway-url" {
  value = "https://${aws_api_gateway_rest_api.contact_form_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.aws_api_gateway_stage_name}/contact-form"
  description = "Endpoint URL for the contact form API"
}