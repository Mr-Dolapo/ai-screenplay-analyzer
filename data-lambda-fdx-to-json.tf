# Data block to create zip file containing lambda runtime script
data "archive_file" "fdx_to_json_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/fdx-to-json"
  output_path = "${path.module}/lambda-functions/build/fdx_to_json.zip"
}

# Data block to create JSON policy for lambda role permissions
data "aws_iam_policy_document" "fdx_to_json_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.s3_data_bucket.arn}/fdx/*"
    ]
  }

  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.s3_data_bucket.arn}/json/*"
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

# Data block to create JSON policy permitting specified entities to assume role
data "aws_iam_policy_document" "assume_role_policy_fdx_to_json" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
