terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }

  cloud {
    organization = "brightblueray"
    workspaces {
      name = "demo-vault-infra"
    }
  }
}

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

# provider "aws" {
#   alias  = "hadr-region"
#   region = var.hadr-vpc-region
# }

module "secrets" {
  source = "./secrets/"
  providers = {
    aws = aws.primary-region
  }
  resource_name_prefix = var.prefix
}

# resource "aws_kms_key" "rryjewski-vault-unseal" {
#   description             = "KMS Vault Unseal Key"
#   deletion_window_in_days = 10
#   multi_region = true
# }

module "vpc-primary" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  providers = {
    aws = aws.primary-region
  }

  name = "${var.prefix}-primaryClusterVpc"
  cidr = "10.0.0.0/16"

  azs             = var.vpc-primary-azs
  private_subnets = var.vpc-primary-priv-subnets
  public_subnets  = var.vpc-primary-pub-subnets

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = true
  create_igw             = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "rryjewski"
  }
}

# module "hadr-vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "3.14.2"
#   providers = {
#     aws = aws.hadr-region
#   }

#   # insert the 23 required variables here
#   name = "${var.prefix}-hadrClusterVpc"
#   cidr = "20.0.0.0/16"

#   azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   private_subnets = ["20.0.1.0/24", "20.0.2.0/24", "20.0.3.0/24"]
#   public_subnets = ["20.0.101.0/24", "20.0.102.0/24", "20.0.103.0/24"]

#   enable_nat_gateway = true
#   one_nat_gateway_per_az = false
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

# resource "aws_vpc_peering_connection" "primary" {
#   # provider = aws.primary-region
#   vpc_id = module.primary-vpc.vpc_id
#   peer_vpc_id = module.hadr-vpc.vpc_id
#   auto_accept = false
#   peer_region = var.hadr-vpc-region

#   tags = {
#     "Side" = "Requester"
#   }
# }

# resource "aws_vpc_peering_connection_accepter" "hadr" {
#   provider = aws.hadr-region
#   vpc_peering_connection_id = aws_vpc_peering_connection.primary.id
#   auto_accept = true

#   tags = {
#     Side = "Accepter"
#   }
# } 

# resource "aws_vpc_peering_connection_options" "requester" {
#   # provider = aws.primary-region
#   vpc_peering_connection_id = aws_vpc_peering_connection.primary.id

#   requester {
#     allow_vpc_to_remote_classic_link = false
#     allow_classic_link_to_remote_vpc = false
#   }
# }

# resource "aws_vpc_peering_connection_options" "accepter" {
#   provider = aws.hadr-region
#   vpc_peering_connection_id = aws_vpc_peering_connection_accepter.hadr.id

#   accepter {
#     allow_remote_vpc_dns_resolution = false
#   } 
# }