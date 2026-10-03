resource "aws_lambda_function" "isolated" {
  function_name = var.isolated_function_name
  role          = var.isolated_role_arn

  runtime          = var.runtime
  handler          = "handler.handler"
  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256

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