// S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.aws_s3_bucket_name
    
    tags = {
        Name = "PremierMortgage Website Bucket"
    }
}

// S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
    bucket = aws_s3_bucket.s3_bucket.id 
    rule {
        object_ownership = "BucketOwnerPreferred"
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

// Add index.html to the S3 bucket
resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "index.html"
    source = "${path.module}/../frontend/index.html"
    content_type = "text/html"

    etag = filemd5("${path.module}/../frontend/index.html")
}

// Add style.css to the S3 bucket
resource "aws_s3_object" "style_css" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "styles.css"
    source = "${path.module}/../frontend/styles.css"
    content_type = "text/css"

    etag = filemd5("${path.module}/../frontend/styles.css")
}   

// Add script.js to the S3 bucket
resource "aws_s3_object" "script_js" {
    bucket = aws_s3_bucket.s3_bucket.id
    key    = "script.js"
    source = "${path.module}/../frontend/script.js"
    content_type = "application/javascript"

    etag = filemd5("${path.module}/../frontend/script.js")
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
    hash_key = "referenceId"

    // stream_enabled = true // Enabled to trigger Lambda function
    // stream_view_type = "NEW_IMAGE" // Capture new item creation

    deletion_protection_enabled = false // Disable deletion protection for the table for project

    attribute {
        name = "referenceId"
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
        Name = "Premier Mortgage Contact Form Responses"
    }
}


// SES Email Identity
resource "aws_ses_email_identity" "email_identity" {
    email = var.aws_ses_email_identity
}   
