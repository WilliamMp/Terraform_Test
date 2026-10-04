variable "project_name" {
  description = "Project name used to identify resources."
  type        = string
}

variable "s3_endpoint_id" {
  description = "S3 VPC endpoint required for object uploads and downloads."
  type        = string
}

variable "isolated_lambda_role_arn" {
  description = "Execution role permitted to access stored objects."
  type        = string
}