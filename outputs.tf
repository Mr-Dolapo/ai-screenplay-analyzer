# Output the full URL endpoint for the POST /upload API route
output "upload_api_endpoint" {
  value = "${aws_apigatewayv2_api.fdx_upload_api.api_endpoint}/upload"
}

# Output the full URL endpoint for the GET /evaluation API route
output "evaluation_api_endpoint" {
  value = "${aws_apigatewayv2_api.fdx_upload_api.api_endpoint}/evaluation"
}
