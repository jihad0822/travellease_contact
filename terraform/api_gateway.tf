// Create Regional RestAPI
resource "aws_api_gateway_rest_api" "contact_form_api" {
    name = var.aws_api_gateway_rest_api_name
    description = "API for Contact Form"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

// Create API Gateway Resource
resource "aws_api_gateway_resource" "contact_form" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    parent_id = aws_api_gateway_rest_api.contact_form_api.root_resource_id
    path_part = "contact-form"
}   


// Create API Gateway POST Method
resource "aws_api_gateway_method" "contact_form_post_method" {
    rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
    resource_id   = aws_api_gateway_resource.contact_form.id
    http_method   = "POST"
    authorization = "NONE"  
}

// Create API Gateway POST Integration
resource "aws_api_gateway_integration" "contact_form_post_integration" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_post_method.http_method
    type        = "AWS_PROXY"
    integration_http_method = "POST"
    uri         = aws_lambda_function.contact_form_lambda_handler.invoke_arn    
}  

// Create API Gateway OPTIONS Method for CORS
resource "aws_api_gateway_method" "contact_form_cors_method" {
    rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
    resource_id   = aws_api_gateway_resource.contact_form.id
    http_method   = "OPTIONS"
    authorization = "NONE"  
}

// Create API Gateway Integration for CORS
resource "aws_api_gateway_integration" "contact_form_cors_integration" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_cors_method.http_method
    type = "MOCK"
    integration_http_method = "OPTIONS"
    request_templates = {
        "application/json" = jsonencode({
            statusCode = 200
        })
    }

    depends_on = [ 
        aws_api_gateway_method.contact_form_cors_method 
    ]
}

// Create API Gateway Method Response for POST
resource "aws_api_gateway_method_response" "contact_form_post_method_response" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_post_method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true 
    }
}

// Create API Gateway Method Response for CORS
resource "aws_api_gateway_method_response" "contact_form_cors_method_response" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_cors_method.http_method
    status_code = "200" 

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
    }
}

// Create Integration Response for CORS
resource "aws_api_gateway_integration_response" "contact_form_cors_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    resource_id = aws_api_gateway_resource.contact_form.id
    http_method = aws_api_gateway_method.contact_form_cors_method.http_method
    status_code = aws_api_gateway_method_response.contact_form_cors_method_response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    }
}

// Create API Gateway Deployment
resource "aws_api_gateway_deployment" "contact_form_deployment" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id   

    // Redeployment when API changes
    triggers = {
        redeploy = sha1(jsonencode([
            aws_api_gateway_resource.contact_form.id,
            aws_api_gateway_method.contact_form_post_method.id,
            aws_api_gateway_method.contact_form_cors_method.id,
            aws_api_gateway_integration.contact_form_post_integration.id,
            aws_api_gateway_integration.contact_form_cors_integration.id,   
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [ 
        aws_api_gateway_method.contact_form_post_method,
        aws_api_gateway_integration.contact_form_post_integration,
        aws_api_gateway_method.contact_form_cors_method,
        aws_api_gateway_integration.contact_form_cors_integration,
        aws_api_gateway_method_response.contact_form_post_method_response,
        aws_api_gateway_method_response.contact_form_cors_method_response,
        aws_api_gateway_integration_response.contact_form_cors_integration_response,
    ]
}

// Create API Gateway Stage
resource "aws_api_gateway_stage" "contact_form_stage" {
    rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
    stage_name  = "dev"
    deployment_id = aws_api_gateway_deployment.contact_form_deployment.id
}