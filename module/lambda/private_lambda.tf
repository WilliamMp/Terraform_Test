resource "aws_lambda_function" "private" {
  function_name = var.private_function_name
  role          = var.private_role_arn

  runtime          = var.runtime
  handler          = "handler.handler"
  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size

  vpc_config {
    subnet_ids = var.private_subnet_ids

    security_group_ids = [
      var.private_security_group_id
    ]
  }

  depends_on = [aws_cloudwatch_log_group.private]
}