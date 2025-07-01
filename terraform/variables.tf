variable "aws_region" {
  description = "The AWS region where the resources will be created"
  type = string
  default = "ca-central-1"
}


// S3 Variables
variable "aws_s3_bucket_name" {
  description = "The name of the S3 bucket for the static website"
  type = string
  default = "gs-travelease-bucket"
}


// DynamoDB Variables
variable "aws_dynamodb_table_name" {
  description = "The name of the DynamoDB table for storing contact form submissions"
  type = string
  default = "TravelEase-Contact-Form-Responses"
}


// SES Variables
variable "aws_ses_email_identity" {
  description = "The email identity for SES to send emails from"
  type = string
  default = "gur_579@hotmail.com"
}


// API Gateway Variables
variable "aws_api_gateway_name" {
    description = "The name of the API Gateway for the contact form"
    type = string
    default = "TravelEaseAPI-ContactForm"
}


// Lambda Function Variables
variable "lambda_function_name_contact_form" {
    description = "The name of the Lambda function for handling contact form submissions"
    type = string
    default = "TravelEase-Contact-Form-Handler"
}   

variable "lambda_function_name_email_preparation" {
    description = "The name of the Lambda function for preparing and sending emails"
    type = string
    default = "TravelEase-Email-Preparation-Handler"
}


// IAM Role Variables
variable "lambda_iam_role_name" {
    description = "The name of the IAM role for the Lambda function"
    type = string
    default = "TravelEase-Lambda-Role"
}

variable "lambda_iam_role_policy_name" {
    description = "The name of the IAM policy for the Lambda function"
    type = string
    default = "TravelEase-Lambda-Role-Policy"
}