// Create RestAPI
resource "aws_api_gateway_rest_api" "api_gateway" {
    name = var.aws_api_gateway_name
    description = "API for TravelEase Contact Form"
}

// Create API Gateway Resource
resource "aws_api_gateway_resource" "contact_form" {
    rest_api_id = aws_api_gateway_rest_api.api_gateway.id
    parent_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
    path_part = "contact-form"
}   

/* Create API Gateway Method
resource "aws_api_gateway_method" "contact_form_post" {
    rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
    resource_id   = aws_api_gateway_resource.contact_form.id
    http_method   = "POST"
    authorization = "NONE"  
}
*/

/* Create API Gateway Integration
resource "aws_api_gateway_integration" "contact_form_integration" {
    rest_api_id = aws_api_gateway_rest_api.api_gateway.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_post.http_method
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri         = aws_lambda_function.contact_form_lambda.invoke_arn    
}
*/