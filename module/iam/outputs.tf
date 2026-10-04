output "isolated_lambda_role_arn" {
  description = "Execution role ARN for the isolated Lambda."
  value       = aws_iam_role.isolated_lambda.arn
}


output "private_lambda_role_arn" {
  description = "Execution role ARN for the private Lambda."
  value       = aws_iam_role.private_lambda.arn
}

output "private_lambda_role_name" {
  description = "Name of the private Lambda execution role."
  value       = aws_iam_role.private_lambda.name
}