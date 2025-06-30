#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION FDX TO JSON
#################################################################################

# IAM Role for the Lambda function that converts .fdx files to JSON
resource "aws_iam_role" "lambda_fdx_to_json" {
  name               = "lambda-fdx-to-json-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_fdx_to_json.json
}

# Attach the specific access policy to the FDX-to-JSON Lambda role
resource "aws_iam_role_policy" "fdx_to_json_policy" {
  name   = "fdx-to-json-access-policy"
  role   = aws_iam_role.lambda_fdx_to_json.id
  policy = data.aws_iam_policy_document.fdx_to_json_policy.json
}

#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION JSON TO EVAL
#################################################################################

# IAM Role for the Lambda function that processes JSON to generate evaluations
resource "aws_iam_role" "lambda_json_to_eval" {
  name               = "lambda-json-to-eval-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_json_to_eval.json
}

# Attach the specific access policy to the JSON-to-Eval Lambda role
resource "aws_iam_role_policy" "json_to_eval_policy" {
  name   = "fdx-to-json-access-policy"
  role   = aws_iam_role.lambda_json_to_eval.id
  policy = data.aws_iam_policy_document.json_to_eval_policy.json
}

#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION POST FDX
#################################################################################

# IAM Role for the Lambda function that uploads .fdx files to the S3 bucket
resource "aws_iam_role" "lambda_post_fdx" {
  name               = "lambda-post-fdx-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_post_fdx.json
}

# Attach the specific access policy to the POST FDX Lambda role
resource "aws_iam_role_policy" "post_fdx_policy" {
  name   = "post-fdx-access-policy"
  role   = aws_iam_role.lambda_post_fdx.id
  policy = data.aws_iam_policy_document.post_fdx_policy.json
}
