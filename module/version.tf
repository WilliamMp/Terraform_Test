terraform {
  required_version = ">= 1.16"
    # https://github.com/hashicorp/terraform/pull/38352
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}