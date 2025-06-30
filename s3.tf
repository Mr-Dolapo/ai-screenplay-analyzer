# S3 Bucket to store .fdx, .json, and bedrock evaluation files

# Create the S3 bucket with object lock enabled and lifecycle protection to prevent accidental deletion
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

# Enable versioning on the S3 bucket to keep track of changes to objects
resource "aws_s3_bucket_versioning" "s3_data_bucket_versioning" {
  bucket = aws_s3_bucket.s3_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption using AES256 for all objects in the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_data_bucket_encryption" {
  bucket = aws_s3_bucket.s3_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configure S3 bucket notifications to trigger Lambda functions on object creation events for specific prefixes and suffixes
resource "aws_s3_bucket_notification" "trigger_lambdas" {
  bucket = aws_s3_bucket.s3_data_bucket.id

  # Trigger lambda_fdx_to_json when a new .fdx file is created under "fdx/" prefix
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_fdx_to_json.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "fdx/"
    filter_suffix       = ".fdx"
  }

  # Trigger lambda_json_to_eval when a new .json file is created under "json/" prefix
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_json_to_eval.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "json/"
    filter_suffix       = ".json"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_fdx,
    aws_lambda_permission.allow_s3_invoke_json
  ]
}
