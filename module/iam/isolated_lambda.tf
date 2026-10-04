resource "aws_iam_role" "isolated_lambda" {
  name = "${var.project_name}-isolated-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "isolated_lambda_s3" {
  name = "${var.project_name}-isolated-s3-upload"
  role = aws_iam_role.isolated_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "UploadProcessedData"
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${var.bucket_arn}/processed/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "isolated_lambda_vpc" {
  role = aws_iam_role.isolated_lambda.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
