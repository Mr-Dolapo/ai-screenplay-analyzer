# Define HTTP API Gateway named "fdx-upload-api"
resource "aws_apigatewayv2_api" "fdx_upload_api" {
  name          = "fdx-upload-api"
  protocol_type = "HTTP"
}

# Integration to connect API Gateway with Lambda using AWS_PROXY (proxy integration)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                  = aws_apigatewayv2_api.fdx_upload_api.id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.lambda_post_fdx.invoke_arn
  integration_method      = "POST"
  payload_format_version  = "2.0"
}

# Define POST /upload route linked to Lambda integration
resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.fdx_upload_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Define GET /evaluation route using the same Lambda integration
resource "aws_apigatewayv2_route" "get_upload_result_route" {
  api_id    = aws_apigatewayv2_api.fdx_upload_api.id
  route_key = "GET /evaluation"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deploy the API with default stage that auto-deploys on changes
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.fdx_upload_api.id
  name        = "$default"
  auto_deploy = true
}
