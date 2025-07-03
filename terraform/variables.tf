variable "aws_region" {
  description = "The AWS region where the resources will be created"
  type = string
  default = "ca-central-1"
}


// S3 Variables
variable "aws_s3_bucket_name" {
  description = "The name of the S3 bucket for the static website"
  type = string
  default = "gs-premier-mortgage-bucket"
}


// DynamoDB Variables
variable "aws_dynamodb_table_name" {
  description = "The name of the DynamoDB table for storing contact form submissions"
  type = string
  default = "PremierMortgage-ContactForm-Responses"
}


// SES Variables
variable "aws_ses_email_identity" {
  description = "The email identity for SES to send emails from"
  type = string
  default = "gur_579@hotmail.com"
}


// API Gateway Variables
variable "aws_api_gateway_rest_api_name" {
    description = "The name of the API Gateway for the contact form"
    type = string
    default = "PremierMortgage-API-ContactForm"
}

variable "aws_api_gateway_stage_name" {
  description = "The name of the API Gateway Stage Name"
  type = string
  default = "dev"
}


// Lambda Function Variables
variable "lambda_function_name_contact_form" {
    description = "The name of the Lambda function for handling contact form submissions"
    type = string
    default = "PremierMortgage-Contact-Form-Handler"
}   

variable "lambda_iam_role_name" {
    description = "The name of the IAM role for the Lambda function"
    type = string
    default = "PremierMortgage-Lambda-Role"
}

variable "lambda_iam_role_policy_name" {
    description = "The name of the IAM policy for the Lambda function"
    type = string
    default = "PremierMortgage-Lambda-Role-Policy"
}