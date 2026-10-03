resource "aws_s3_bucket" "data" {
  bucket_prefix = "${var.project_name}-data-"

  tags = {
    Name = "${var.project_name}-data"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


#enforce
resource "aws_s3_bucket_ownership_controls" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}





#--Policy
#--------

resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyObjectTransferOutsideEndpoint"
        Effect    = "Deny"
        Principal = "*"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.data.arn}/*"

        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = var.s3_endpoint_id
          }
        }
      },
      {
        Sid       = "DenyObjectAccessFromOtherIdentities"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "${aws_s3_bucket.data.arn}/*"

        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = var.isolated_lambda_role_arn
          }
        }
      }
    ]
  })
}