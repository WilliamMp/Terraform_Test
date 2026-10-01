variable "project_name" {
  description = "Project name used to identify resources."
  type        = string
}

variable "api_endpoint_id" {
  description = "Existing execute-api VPC endpoint ID."
  type        = string
}

variable "private_lambda_role_arn" {
  description = "Execution role allowed to call the private API."
  type        = string
}

variable "isolated_function_name" {
  description = "Name of the isolated Lambda."
  type        = string
}

variable "isolated_invoke_arn" {
  description = "Lambda invocation ARN for API Gateway integration."
  type        = string
}


variable "stage_name" {
  description = "Stage name for the API."
  type        = string
}


variable "private_function_name" {
  description = "Name of the private Lambda."
  type        = string
}

variable "private_invoke_arn" {
  description = "Private Lambda invocation ARN for API Gateway."
  type        = string
}