resource "aws_api_gateway_rest_api" "private" {
  name        = "${var.project_name}-private-api"
  description = "Private API for sensitive-data processing"

  endpoint_configuration {
    types = ["PRIVATE"]

    vpc_endpoint_ids = [
      var.api_endpoint_id
    ]
  }
}

resource "aws_api_gateway_rest_api_policy" "private" {
  rest_api_id = aws_api_gateway_rest_api.private.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "AllowProcessingRequest"
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.private.execution_arn}/*/POST/process"
      },
      {
        Sid       = "DenyOutsideEndpoint"
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.private.execution_arn}/*"

        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = var.api_endpoint_id
          }
        }
      },
      {
        Sid       = "DenyOtherCallers"
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${aws_api_gateway_rest_api.private.execution_arn}/*"

        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = var.private_lambda_role_arn
          }
        }
      }
    ]
  })
}


resource "aws_api_gateway_resource" "process" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_rest_api.private.root_resource_id
  path_part   = "process"
}

resource "aws_api_gateway_method" "process_post" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.process.id

  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "process_lambda" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.process.id
  http_method = aws_api_gateway_method.process_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.isolated_invoke_arn
}


resource "aws_lambda_permission" "private_api" {
  statement_id  = "AllowPrivateApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.isolated_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.private.execution_arn}/*/POST/process"
}




resource "aws_api_gateway_deployment" "private" {
  rest_api_id = aws_api_gateway_rest_api.private.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.process.path_part,
      aws_api_gateway_method.process_post.http_method,
      aws_api_gateway_method.process_post.authorization,
      aws_api_gateway_integration.process_lambda.type,
      aws_api_gateway_integration.process_lambda.integration_http_method,
      aws_api_gateway_integration.process_lambda.uri,
      aws_api_gateway_rest_api_policy.private.policy
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.process_lambda,
    aws_api_gateway_rest_api_policy.private,
    aws_lambda_permission.private_api
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "private" {
  rest_api_id   = aws_api_gateway_rest_api.private.id
  deployment_id = aws_api_gateway_deployment.private.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.private_api.arn

    format = jsonencode({
      requestId       = "$context.requestId"
      httpMethod      = "$context.httpMethod"
      resourcePath    = "$context.resourcePath"
      status          = "$context.status"
      responseLatency = "$context.responseLatency"
      responseLength  = "$context.responseLength"
    })
  }

  depends_on = [aws_api_gateway_account.logging]
}