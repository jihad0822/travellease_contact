// S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
    bucket = var.aws_s3_bucket_name
    
    tags = {
        Name = "Contact Form Website Bucket"
    }
}

// S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
    bucket = aws_s3_bucket.s3_bucket.id 
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

// S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
    bucket = aws_s3_bucket.s3_bucket.id 
    index_document {
        suffix = "index.html"
    }
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

    depends_on = [ aws_s3_bucket_public_access_block.s3_bucket_public_access_block ]
} 


// Create DynamoDB 
resource "aws_dynamodb_table" "dynamodb_table" {
    name = var.aws_dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "referenceId"

    deletion_protection_enabled = false // Disable deletion protection for the table for dev

    attribute {
        name = "referenceId"
        type = "S"
    }

    tags = {
        Name = "Contact Form Responses Database"
    }
}


// SES Email Identity
resource "aws_ses_email_identity" "email_identity" {
    email = var.aws_ses_email_identity
}   

// SES Configuration Set to track bounce/complaints
resource "aws_ses_configuration_set" "ses_configuration_set" {
    name = var.aws_ses_configuration_set
    
    delivery_options {
        tls_policy = "Require"
    }
    
    reputation_metrics_enabled = true
}

// SES Configuration Set Destination
resource "aws_ses_event_destination" "ses_event_destination" {
  name                   = "${var.aws_ses_configuration_set}-event-destination"
  configuration_set_name = aws_ses_configuration_set.ses_configuration_set.name
  enabled                = true
  matching_types         = ["bounce", "complaint"]

  cloudwatch_destination {
    default_value = "0"
    dimension_name = "dimension"
    value_source = "messageTag"
  }
}
