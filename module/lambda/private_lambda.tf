resource "aws_lambda_function" "private" {
  function_name = var.private_function_name
  role          = var.private_role_arn

  runtime          = var.runtime
  handler          = "handler.handler"
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  timeout     = var.timeout
  memory_size = var.memory_size

  vpc_config {
    subnet_ids = var.private_subnet_ids

    security_group_ids = [
      var.private_security_group_id
    ]
  }
}