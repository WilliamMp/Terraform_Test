output "private_function_name" {
  description = "Private Lambda name for invocation permissions."
  value       = aws_lambda_function.private.function_name
}

output "private_invoke_arn" {
  description = "Private Lambda invocation ARN for API Gateway."
  value       = aws_lambda_function.private.invoke_arn
}

output "isolated_function_name" {
  description = "Isolated Lambda name for invocation permissions."
  value       = aws_lambda_function.isolated.function_name
}

output "isolated_invoke_arn" {
  description = "Isolated Lambda invocation ARN for API Gateway."
  value       = aws_lambda_function.isolated.invoke_arn
}