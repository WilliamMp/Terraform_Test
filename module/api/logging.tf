resource "aws_iam_role" "api_logging" {
  name = "${var.project_name}-api-logging"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "apigateway.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_logging" {
  role = aws_iam_role.api_logging.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "logging" {
  cloudwatch_role_arn = aws_iam_role.api_logging.arn

  depends_on = [
    aws_iam_role_policy_attachment.api_logging
  ]
}

resource "aws_cloudwatch_log_group" "public_api" {
  name              = "/aws/apigateway/${var.project_name}-public"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "private_api" {
  name              = "/aws/apigateway/${var.project_name}-private"
  retention_in_days = var.log_retention_days
}