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


# SNS Topic
resource "aws_sns_topic" "lambda_error" {
  name = "${var.lambda_function_name_contact_form}-errors"  # Use variable for consistency
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "lambda_error_notification_email" {
  topic_arn  = aws_sns_topic.lambda_error.arn
  protocol   = "email"
  endpoint   = var.aws_sns_topic_subscription
  depends_on = [aws_sns_topic.lambda_error]
}

# Diagnostic Outputs
output "sns_topic_arn" {
  value       = aws_sns_topic.lambda_error.arn
  description = "ARN of the SNS topic"
}

output "sns_topic_name" {
  value       = aws_sns_topic.lambda_error.name
  description = "Name of the SNS topic"
}

output "sns_subscription_endpoint" {
  value       = var.aws_sns_topic_subscription
  description = "Email endpoint for SNS subscription"
}
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form_lambda_handler.function_name}"
  retention_in_days = 14  # Adjust retention as needed
}

// CloudWatch Log Metric Filter to catch ERROR/Error patterns
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${aws_lambda_function.contact_form_lambda_handler.function_name}-error-metric-filter"
  log_group_name = "/aws/lambda/${aws_lambda_function.contact_form_lambda_handler.function_name}"
  pattern        = "ERROR"

  metric_transformation {
    name = "ErrorCount"
    namespace = "Lambda/Errors"
    value = "1"
    default_value = "0"
  }
  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}


resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  provider            = aws  # Explicitly use the us-east-1 provider
  alarm_name          = "${aws_lambda_function.contact_form_lambda_handler.function_name}-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ErrorCount"
  namespace           = "Lambda/Errors"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alert when Lambda logs contain ERROR"
  alarm_actions       = [aws_sns_topic.lambda_error.arn]
  treat_missing_data  = "notBreaching"

  tags = {
    Name = "${aws_lambda_function.contact_form_lambda_handler.function_name}-error-alarm"
  }
}
