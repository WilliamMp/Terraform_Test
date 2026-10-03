resource "aws_cloudwatch_log_group" "private" {
  name              = "/aws/lambda/${var.private_function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "isolated" {
  name              = "/aws/lambda/${var.isolated_function_name}"
  retention_in_days = var.log_retention_days
}