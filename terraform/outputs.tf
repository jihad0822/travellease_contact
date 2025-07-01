output "aws_s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
  description = "Name of static website S3 Bucket"
}

output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.dynamodb_table.name
  description = "Name of the DynamoDB table for storing contact form submissions"
}

output "aws_ses_email_identity" {
  value = aws_ses_email_identity.email_identity.email
  description = "Email identity for SES to send emails from"
}

output "aws_api_gateway_name" {
  value = aws_api_gateway_rest_api.api_gateway.name
  description = "Name of the API Gateway for the contact form"
}

output "lambda_iam_role_name" {
  value = aws_iam_role.lambda_iam_role.name
  description = "Name of the IAM role for the Lambda function"
}

output "lambda_iam_role_policy_name" {
  value = aws_iam_role_policy.lambda_iam_role_policy.name
  description = "Name of the IAM policy for the Lambda function"
}

/*
output "lambda_function_name_contact_form" {
  value = aws_lambda_function.contact_form_lambda_handler.function_name
  description = "Name of the Lambda function for handling contact form submissions"
}

output "lambda_function_name_email_preparation" {
  value = aws_lambda_function.email_preparation_lambda_handler.function_name
  description = "Name of the Lambda function for preparing and sending emails"
}
*/