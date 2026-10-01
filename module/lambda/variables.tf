variable "private_function_name" {
  description = "Name of the private Lambda function."
  type        = string
}

variable "isolated_function_name" {
  description = "Name of the isolated Lambda function."
  type        = string
}

variable "runtime" {
  description = "Runtime used by both Lambda functions."
  type        = string
}

variable "timeout" {
  description = "Execution timeout in seconds."
  type        = number
}

variable "memory_size" {
  description = "Memory allocation in MB."
  type        = number
}

variable "private_role_arn" {
  description = "Execution role ARN for the private Lambda."
  type        = string
}

variable "isolated_role_arn" {
  description = "Execution role ARN for the isolated Lambda."
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs for the private Lambda."
  type        = list(string)
}

variable "isolated_subnet_ids" {
  description = "Subnet IDs for the isolated Lambda."
  type        = list(string)
}

variable "private_security_group_id" {
  description = "Security group ID for the private Lambda."
  type        = string
}

variable "isolated_security_group_id" {
  description = "Security group ID for the isolated Lambda."
  type        = string
}

variable "bucket_name" {
  description = "Bucket used to store processed data."
  type        = string
}