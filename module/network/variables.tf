variable "project_name" {
  description = "Project name used to identify resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 address range for the VPC."
  type        = string
}

variable "subnets" {
  description = "Subnet CIDRs, availability zones, and tiers."

  type = map(object({
    cidr = string
    az   = string
    tier = string
  }))
}