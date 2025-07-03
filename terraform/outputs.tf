output "aws-s3-bucket-name" {
  value = aws_s3_bucket.s3_bucket.bucket
  description = "Name of static website S3 Bucket"
}

output "aws-dynamodb-table-name" {
  value = aws_dynamodb_table.dynamodb_table.name
  description = "Name of the DynamoDB table for storing contact form submissions"
}

output "aws-api-gateway-url" {
  value = "https://${aws_api_gateway_rest_api.contact_form_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.aws_api_gateway_stage_name}/contact-form"
  description = "POST Endpoint URL for the contact form API"
}

output "lambda-function-name" {
  value = aws_lambda_function.contact_form_lambda_handler.function_name
  description = "Name of the Lambda function for handling contact form submissions"
}