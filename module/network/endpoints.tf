data "aws_region" "current" {}

# isolating for s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.tier["isolated"].id
  ]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.execute-api"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for key, subnet in var.subnets :
    aws_subnet.subnet[key].id
    if subnet.tier == "isolated"
  ]

  security_group_ids = [
    aws_security_group.api_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-api-endpoint"
  }
}