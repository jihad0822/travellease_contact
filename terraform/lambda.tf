/* Create Lambda Function to handle contact form submissions
resource "aws_lambda_function" "contact_form_lambda_handler" {
    function_name = var.lambda_function_name_contact_form
    description = "Lambda function to handle contact form submissions and store them in DynamoDB"
    role = var.lambda_iam_role_name
    handler = "index.handler"
    runtime = "nodejs22.x"
    timeout = 30

    // source_code_hash = filebase64sha256("lambda.zip") // Ensure you have a lambda.zip file with your Lambda code

    environment {
        variables = {
            DYNAMODB_TABLE_NAME = var.aws_dynamodb_table_name
        }
    }
}

// Create Lambda Function to prepare emails and send them via SES
resource "aws_lambda_function" "email_preparation_lambda_handler" {
    function_name = var.lambda_function_name_email_preparation
    description = "Lambda function to prepare emails and send them via SES"
    role = var.lambda_iam_role_name
    handler = "email_handler.handler"
    runtime = "nodejs22.x"
    timeout = 30   

    // source_code_hash = filebase64sha256("email_lambda.zip") // Ensure you have a email_lambda.zip file with your Lambda code
    
    environment {
        variables = {
            SES_EMAIL_IDENTITY = var.aws_ses_email_identity
        }
    }
}
*/