// Lambda IAM Role
resource "aws_iam_role" "lambda_iam_role" {
    name = var.lambda_iam_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

/* 
 * Lambda IAM Role Policy
 * Store, update, get items in DynamoDB
 * Send emails using SES
 * Write logs to CloudWatch
 */
resource "aws_iam_role_policy" "lambda_iam_role_policy" {
    name = var.lambda_iam_role_policy_name
    role = aws_iam_role.lambda_iam_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem",
                    "dynamodb:GetItem"
                ]
                Resource = "${aws_dynamodb_table.dynamodb_table.arn}"
            },
            {
                Effect = "Allow"
                Action = [
                    "ses:SendEmail",
                    "ses:SendRawEmail"
                ]
                Resource = "${aws_ses_email_identity.email_identity.arn}"
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "*"
            },
        ]
    })
}
