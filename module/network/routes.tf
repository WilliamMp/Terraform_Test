resource "aws_route_table" "tier" {
  for_each = toset(["public", "private", "isolated"])

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${each.key}-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.tier["public"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.tier["private"].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "subnet" {
  for_each = var.subnets

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.tier[each.value.tier].id
}