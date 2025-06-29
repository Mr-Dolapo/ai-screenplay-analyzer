#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION FDX TO JSON
#################################################################################

# IAM Role created for lambda which turns .fdx to .json
resource "aws_iam_role" "lambda_fdx_to_json" {
  name               = "lambda-fdx-to-json-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_fdx_to_json.json
}

# JSON policy attachment to IAM role 
resource "aws_iam_role_policy" "fdx_to_json_policy" {
  name   = "fdx-to-json-access-policy"
  role   = aws_iam_role.lambda_fdx_to_json.id
  policy = data.aws_iam_policy_document.fdx_to_json_policy.json
}

#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION JSON TO EVAL
#################################################################################

# IAM Role created for lambda which turns .fdx to .json
resource "aws_iam_role" "lambda_json_to_eval" {
  name               = "lambda-json-to-eval-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_json_to_eval.json
}

# JSON policy attachment to IAM role 
resource "aws_iam_role_policy" "json_to_eval_policy" {
  name   = "fdx-to-json-access-policy"
  role   = aws_iam_role.lambda_json_to_eval.id
  policy = data.aws_iam_policy_document.json_to_eval_policy.json
}