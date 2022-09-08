terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
    hcp = {
      source = "hashicorp/hcp"
    }
  }

  cloud {
    organization = "brightblueray"
    workspaces {
      name = "demo-vault-infra"
    }
  }
}

provider "hcp" {}

provider "aws" {
  alias  = "primary-region"
  region = var.vpc-primary-region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Workspace   = "AWS VPC"
      Purpose     = "Vault_Enterprise_Demo"
      Owner       = "rryjewski"
    }
  }
}

provider "aws" {
  alias  = "hadr-region"
  region = var.hadr-vpc-region
}
