#S3 Bucket to store remote terrafrom statefile

# S3 Bucket Itself
resource "aws_s3_bucket" "s3_state_bucket" {
  bucket              = "s3-state-bucket-dolapo-ai-screenplay-analyzer"
  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "s3StateBucket"
  }
}

# Versioning block to add versioning feature to statefile bucket
resource "aws_s3_bucket_versioning" "s3_state_bucket_versioning" {
  bucket = aws_s3_bucket.s3_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption block to add encryption to statefile bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_state_bucket_encryption" {
  bucket = aws_s3_bucket.s3_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}