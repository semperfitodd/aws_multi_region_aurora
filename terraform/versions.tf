provider "aws" {
  region = local.region_0

  default_tags {
    tags = {
      Owner       = var.my_name
      Project     = "AWS Multi Region Aurora with active/active setup"
      Provisioner = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "eu-west-1"
  region = local.region_1

  default_tags {
    tags = {
      Owner       = var.my_name
      Project     = "AWS Multi Region Aurora with active/active setup"
      Provisioner = "Terraform"
    }
  }
}

terraform {
  required_version = "~> 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.61.0"
    }
  }
}