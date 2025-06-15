#################################################################################
# IAM SETUP FOR LAMBDA FUNCTION FDX TO JSON
#################################################################################

resource "aws_iam_role" "lambda_fdx_to_json" {
  name                = "lambda-fdx-to-json-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy_fdx_to_json.json
}


resource "aws_iam_role_policy" "fdx_to_json_policy" {
  name   = "fdx-to-json-access-policy"
  role   = aws_iam_role.lambda_fdx_to_json.id
  policy = data.aws_iam_policy_document.fdx_to_json_policy.json
}