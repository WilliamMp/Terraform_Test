variable "project_name" {
  description = "Project name used to identify resources."
  type        = string
}

variable "public_stage_arn" {
  description = "API Gateway stage ARN to protect."
  type        = string
}