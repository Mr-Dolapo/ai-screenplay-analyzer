# Lambda function resource responsible for uploading .fdx files to the S3 bucket
resource "aws_lambda_function" "lambda_post_fdx" {
  filename         = data.archive_file.post_fdx_lambda_zip.output_path
  function_name    = "lambda_post_fdx"
  role             = aws_iam_role.lambda_post_fdx.arn  # IAM role with permissions for this Lambda
  handler          = "main.handler"                    # Entry point of the Lambda function code
  runtime          = "python3.11"                       # Runtime environment
  timeout          = 60                                 # Timeout in seconds
  source_code_hash = data.archive_file.post_fdx_lambda_zip.output_base64sha256

  environment {
    variables = {
      UPLOAD_BUCKET = aws_s3_bucket.s3_data_bucket.bucket # S3 bucket name for uploads
      FDX_PREFIX    = "fdx/"                              # Prefix folder in S3 bucket
    }
  }
}

# Permission resource to allow API Gateway to invoke this Lambda function
resource "aws_lambda_permission" "allow_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_post_fdx.function_name
  principal     = "apigateway.amazonaws.com"             # Service allowed to invoke
  source_arn    = "${aws_apigatewayv2_api.fdx_upload_api.execution_arn}/*/*" # API Gateway ARN pattern
}
