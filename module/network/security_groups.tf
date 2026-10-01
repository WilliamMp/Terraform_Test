resource "aws_security_group" "private_lambda" {
  name_prefix = "${var.project_name}-private-lambda-"
  description = "Network access for the private Lambda"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-lambda-sg"
  }
}

resource "aws_security_group" "api_endpoint" {
  name_prefix = "${var.project_name}-api-endpoint-"
  description = "HTTPS access to the private API endpoint"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-api-endpoint-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "lambda_to_api" {
  security_group_id            = aws_security_group.private_lambda.id
  referenced_security_group_id = aws_security_group.api_endpoint.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from private Lambda to API endpoint"
}

resource "aws_vpc_security_group_ingress_rule" "api_from_lambda" {
  security_group_id            = aws_security_group.api_endpoint.id
  referenced_security_group_id = aws_security_group.private_lambda.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Accept HTTPS from private Lambda"
}

resource "aws_vpc_security_group_egress_rule" "private_lambda_https" {
  security_group_id = aws_security_group.private_lambda.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow outbound HTTPS"
}


resource "aws_security_group" "isolated_lambda" {
  name_prefix = "${var.project_name}-isolated-lambda-"
  description = "Network access for the isolated Lambda"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-isolated-lambda-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "isolated_lambda_s3" {
  security_group_id = aws_security_group.isolated_lambda.id

  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id
  ip_protocol    = "tcp"
  from_port      = 443
  to_port        = 443

  description = "Allow HTTPS to S3"
}