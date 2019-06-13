
# API gateway creation

  resource "aws_api_gateway_rest_api" "example" {
#  name        = "ServerlessExample"
   name        = "${var.api_name}"
  description = "Terraform Serverless Application Example"
}

  resource "aws_api_gateway_resource" "rest" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "rest"
}

  resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.rest.id}"
  http_method   = "GET"
  authorization = "NONE"
}

  resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
  # uri                     = "${aws_lambda_function.lambda_with_vpc.invoke_arn}"
   uri                     = "arn:aws:apigateway:ap-southeast-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_with_vpc.arn}/invocations"
   }



  resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
#    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}


# API stage
  resource "aws_api_gateway_stage" "example" {
  stage_name    = "prod"
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  deployment_id = "${aws_api_gateway_deployment.example.id}"
}

#API Lambda

  resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_with_vpc.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:ap-southeast-1:973417672605:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.method.http_method}/${aws_api_gateway_resource.rest.path}"
}


