# Data block to create zip file containing lambda runtime script
data "archive_file" "post_fdx_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/post-fdx"
  output_path = "${path.module}/lambda-functions/build/post-fdx.zip"
}

# Data block to create JSON policy for lambda role permissions (upload to fdx/ and read bedrock-evaluations/)
data "aws_iam_policy_document" "post_fdx_policy" {
  statement {
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.s3_data_bucket.arn}/fdx/*",
      "${aws_s3_bucket.s3_data_bucket.arn}/bedrock-evaluations/*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Data block to allow Lambda to assume the role
data "aws_iam_policy_document" "assume_role_policy_post_fdx" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
