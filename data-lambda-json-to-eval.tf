# Data block to create zip file containing lambda runtime script
data "archive_file" "json_to_eval_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/json-to-eval"
  output_path = "${path.module}/lambda-functions/build/json_to_eval.zip"
}

# Data block to create JSON policy for lambda role permissions
data "aws_iam_policy_document" "json_to_eval_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.s3_data_bucket.arn}/json/*"
    ]
  }

  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.s3_data_bucket.arn}/bedrock-evaluations/*"
    ]
  }

  statement {
    actions = ["bedrock:InvokeModel"]
    resources = [
      "arn:aws:bedrock:eu-west-2::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
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
data "aws_iam_policy_document" "assume_role_policy_json_to_eval" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
