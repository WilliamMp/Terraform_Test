


locals {
  project_name = "devops-test"

  aws_region   = "us-east-1"
  
  vpc_cidr     = "10.0.0.0/16"

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
}
