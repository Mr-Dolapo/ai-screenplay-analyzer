#S3 Bucket to store .fdx, .json and bedrock evaluation files.

# S3 Bucket Itself
resource "aws_s3_bucket" "s3_data_bucket" {
  bucket              = "s3-data-bucket-dolapo-ai-screenplay-analyzer"
  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "s3DataBucket"
  }
}

# Versioning block to add versioning feature to data bucket
resource "aws_s3_bucket_versioning" "s3_data_bucket_versioning" {
  bucket = aws_s3_bucket.s3_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption block to add encryption to data bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_data_bucket_encryption" {
  bucket = aws_s3_bucket.s3_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}