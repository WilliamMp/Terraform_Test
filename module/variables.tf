variable "lambda_runtime" {
  description = "Runtime used by both Lambda functions."
  type        = string
  default     = "python3.13"
}

variable "lambda_timeout" {
  description = "Lambda execution timeout in seconds."
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory allocation in MB."
  type        = number
  default     = 128
}


variable "api_stage_name" {
  description = "Stage name for the API."
  type        = string
  default     = "dev"
}







locals {
  project_name = "devops-test"

  aws_region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"

  private_lambda_name = "${local.project_name}-private"

  isolated_lambda_name = "${local.project_name}-isolated"

  subnets = {
    public_a = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
      tier = "public"
    }
    public_b = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
      tier = "public"
    }
    private_a = {
      cidr = "10.0.11.0/24"
      az   = "us-east-1a"
      tier = "private"
    }
    private_b = {
      cidr = "10.0.12.0/24"
      az   = "us-east-1b"
      tier = "private"
    }
    isolated_a = {
      cidr = "10.0.21.0/24"
      az   = "us-east-1a"
      tier = "isolated"
    }
    isolated_b = {
      cidr = "10.0.22.0/24"
      az   = "us-east-1b"
      tier = "isolated"
    }
  }


  runtime = var.lambda_runtime

  timeout = var.lambda_timeout

  memory_size = var.lambda_memory_size


}
