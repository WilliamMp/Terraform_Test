output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = [
    aws_subnet.subnet["private_a"].id,
    aws_subnet.subnet["private_b"].id
  ]
}

output "isolated_subnet_ids" {
  value = [
    aws_subnet.subnet["isolated_a"].id,
    aws_subnet.subnet["isolated_b"].id
  ]
}

output "private_lambda_security_group_id" {
  value = aws_security_group.private_lambda.id
}

output "isolated_lambda_security_group_id" {
  value = aws_security_group.isolated_lambda.id
}

output "api_endpoint_id" {
  value = aws_vpc_endpoint.api.id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}