provider "aws" {
  region = local.aws_region

  default_tags {
    tags = {
      Project   = local.project_name
      ManagedBy = "Terraform"
    }
  }
}

module "network" {
  source = "./network"

  project_name = local.project_name
  vpc_cidr     = local.vpc_cidr
  subnets      = local.subnets
}

module "storage" {
  source = "./storage"

  project_name   = local.project_name
  s3_endpoint_id = module.network.s3_endpoint_id

}

module "iam" {
  source = "./iam"

  project_name = local.project_name
  bucket_arn   = module.storage.bucket_arn

}

module "lambda" {
  source = "./lambda"

  private_function_name  = local.private_lambda_name
  isolated_function_name = local.isolated_lambda_name

  private_role_arn  = module.iam.private_lambda_role_arn
  isolated_role_arn = module.iam.isolated_lambda_role_arn

  private_subnet_ids  = module.network.private_subnet_ids
  isolated_subnet_ids = module.network.isolated_subnet_ids

  private_security_group_id  = module.network.private_lambda_security_group_id
  isolated_security_group_id = module.network.isolated_lambda_security_group_id

  bucket_name = module.storage.bucket_name

  depends_on = [module.iam]
}


module "api" {
  source = "./api"

  project_name    = local.project_name
  api_endpoint_id = module.network.api_endpoint_id

  private_lambda_role_arn = module.iam.private_lambda_role_arn

  isolated_function_name = module.lambda.isolated_function_name
  isolated_invoke_arn    = module.lambda.isolated_invoke_arn

  private_function_name = module.lambda.private_function_name
  private_invoke_arn    = module.lambda.private_invoke_arn

  stage_name = var.api_stage_name
}




#### Resoucer Policy

resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = module.network.s3_endpoint_id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "AllowProcessedDataUploads"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"

        Resource = "${module.storage.bucket_arn}/processed/*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "private_lambda_invoke_api" {
  name = "${local.project_name}-invoke-private-api"
  role = module.iam.private_lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "InvokePrivateProcessing"
        Effect   = "Allow"
        Action   = "execute-api:Invoke"
        Resource = module.api.private_process_execution_arn
      }
    ]
  })
}