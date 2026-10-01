resource "aws_api_gateway_rest_api" "public" {
  name        = "${var.project_name}-public-api"
  description = "Public API for customer-facing requests"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "public_process" {
  rest_api_id = aws_api_gateway_rest_api.public.id
  parent_id   = aws_api_gateway_rest_api.public.root_resource_id
  path_part   = "process"
}


resource "aws_api_gateway_method" "public_process_post" {
  rest_api_id = aws_api_gateway_rest_api.public.id
  resource_id = aws_api_gateway_resource.public_process.id

  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "public_process_lambda" {
  rest_api_id = aws_api_gateway_rest_api.public.id
  resource_id = aws_api_gateway_resource.public_process.id
  http_method = aws_api_gateway_method.public_process_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.private_invoke_arn
}

resource "aws_lambda_permission" "public_api" {
  statement_id  = "AllowPublicApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.private_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.public.execution_arn}/*/POST/process"
}