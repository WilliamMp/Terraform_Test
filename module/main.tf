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
  source = "./modules/network"

  project_name = local.project_name
  vpc_cidr     = local.vpc_cidr
  subnets      = local.subnets
}