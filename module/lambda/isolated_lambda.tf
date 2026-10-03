resource "aws_lambda_function" "isolated" {
  function_name = var.isolated_function_name
  role          = var.isolated_role_arn

  runtime          = var.runtime
  handler          = "handler.handler"
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  timeout     = var.timeout
  memory_size = var.memory_size

  vpc_config {
    subnet_ids = var.isolated_subnet_ids

    security_group_ids = [
      var.isolated_security_group_id
    ]
  }

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }

  depends_on = [aws_cloudwatch_log_group.isolated]
}