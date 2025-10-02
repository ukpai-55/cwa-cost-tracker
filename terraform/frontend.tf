# Random suffix for S3 bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket for frontend
resource "aws_s3_bucket" "frontend" {
  bucket = "cwa-cost-dashboard-${random_id.suffix.hex}"

  website {
    index_document = "index.html"
  }
}

# Allow CloudFront OAI to access S3 bucket
resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.frontend.arn}/*"]
      }
    ]
  })
}



# Upload index.html to S3
resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "index.html"
  source = "../frontend/index.html"
  content_type = "text/html"
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CWA Dashboard"
}


# CloudFront distribution
resource "aws_cloudfront_distribution" "frontend" {
  origin {
  domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
  origin_id   = "S3-Frontend"

  s3_origin_config {
    origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
  }
}


  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Frontend"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "CWA Dashboard"
  }
}
