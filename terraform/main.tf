// S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.aws_s3_bucket_name
    
    tags = {
        Name = "TravelEase Website Bucket"
    }
}

// Allow Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
    bucket = aws_s3_bucket.s3_bucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

// S3 Bucket Policy to allow public read access
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
    bucket = aws_s3_bucket.s3_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
            },
        ]
    })
}

// S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
    bucket = aws_s3_bucket.s3_bucket.id 
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

/* Enable CORS on the S3 bucket
resource "aws_s3_bucket_cors_configuration" "s3_bucket_cors_configuration" {
    bucket = aws_s3_bucket.s3_bucket.id
    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "POST", "PUT"]
        allowed_origins = ["*"]
        expose_headers  = []
        max_age_seconds = 3000
    }
}  */ 

// Add index.html to the S3 bucket
resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "index.html"
    source = "~/CEA/projects/contact_form_aws_project/website/index.html"
    content_type = "text/html"
}

// Add style.css to the S3 bucket
resource "aws_s3_object" "style_css" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "styles.css"
    source = "~/CEA/projects/contact_form_aws_project/website/styles.css"
    content_type = "text/css"
}   

// Add script.js to the S3 bucket
resource "aws_s3_object" "script_js" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "script.js"
    source = "~/CEA/projects/contact_form_aws_project/website/script.js"
    content_type = "application/javascript"
}  

// S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
    bucket = aws_s3_bucket.s3_bucket.id 
    index_document {
        suffix = "index.html"
    }
}   


// Create DynamoDB 
resource "aws_dynamodb_table" "dynamodb_table" {
    name = var.aws_dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "ReferenceId"

    stream_enabled = true // Enabled to trigger Lambda function
    stream_view_type = "NEW_IMAGE" // Capture new item creation

    deletion_protection_enabled = false // Disable deletion protection for the table for project

    attribute {
        name = "ReferenceId"
        type = "S"
    }

    /*
    attribute {
        name = "Name"
        type = "S"
    }

    attribute {
        name = "Email"
        type = "S"
    }

    attribute {
        name = "Body"
        type = "S"
    }
    */
    tags = {
        Name = "TravelEase Contact Form Responses"
    }
}


// SES Email Identity
resource "aws_ses_email_identity" "email_identity" {
    email = var.aws_ses_email_identity
}   
