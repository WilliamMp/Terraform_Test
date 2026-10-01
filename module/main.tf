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
  source = "./s3"

  project_name = local.project_name
  s3_endpoint_id = module.network.s3_endpoint_id

}

module "iam" {
  source = "./iam"

  project_name = local.project_name
  bucket_arn   = module.storage.bucket_arn

}


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