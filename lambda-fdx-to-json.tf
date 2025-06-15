resource "aws_lambda_function" "lambda_fdx_to_json" {
  filename      = data.archive_file.fdx_to_json_lambda_zip.output_path
  function_name = "lambda_fdx_to_json"
  role          = aws_iam_role.lambda_fdx_to_json.arn
  handler       = "main.handler"
  runtime       = "python3.11"
  source_code_hash = data.archive_file.fdx_to_json_lambda_zip.output_base64sha256
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_fdx_to_json.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_data_bucket.arn
}
