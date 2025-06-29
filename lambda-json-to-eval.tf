# Lambda function resource responsible for turning .json into an evaluated .json from bedrock
resource "aws_lambda_function" "lambda_json_to_eval" {
  filename         = data.archive_file.json_to_eval_lambda_zip.output_path
  function_name    = "lambda_json_to_eval"
  role             = aws_iam_role.lambda_json_to_eval.arn
  handler          = "main.handler"
  runtime          = "python3.11"
  timeout          = 60
  source_code_hash = data.archive_file.json_to_eval_lambda_zip.output_base64sha256
}

# Specifies entity able to invoke lambda function, in this case the S3 bucket storing the .json files
resource "aws_lambda_permission" "allow_s3_invoke_json" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_json_to_eval.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_data_bucket.arn
}
