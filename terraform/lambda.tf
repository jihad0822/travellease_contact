// Zip Lambda Function Code
data "archive_file" "contact_form_lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/../lambda"
    output_path = "${path.module}/../contact_form_lambda.zip"
}

// Create Lambda Function to handle contact form submissions
resource "aws_lambda_function" "contact_form_lambda_handler" {
    filename = data.archive_file.contact_form_lambda_zip.output_path
    function_name = var.lambda_function_name_contact_form
    description = "Lambda function to handle contact form submissions"
    role = aws_iam_role.lambda_iam_role.arn
    handler = "index.handler"
    runtime = "nodejs22.x"
    timeout = 30

    source_code_hash = data.archive_file.contact_form_lambda_zip.output_base64sha256

    environment {
        variables = {
            DYNAMODB_TABLE_NAME = var.aws_dynamodb_table_name
            SES_EMAIL_IDENTITY = var.aws_ses_email_identity
        }
    }
}

// Add Lambda function permissions to allow API Gateway to invoke it
resource "aws_lambda_permission" "allow_contact_form_api_gateway" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.contact_form_lambda_handler.function_name
    principal     = "apigateway.amazonaws.com"

    // Source ARN for API Gateway
    source_arn = "${aws_api_gateway_rest_api.contact_form_api.execution_arn}/*/*"
}
