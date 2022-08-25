terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.24.0"
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
  alias = "primary-region"
  region = var.primary-vpc-region
}

provider "aws" {
  alias = "hadr-region"
  region = var.hadr-vpc-region
}

# resource "aws_kms_key" "rryjewski-vault-unseal" {
#   description             = "KMS Vault Unseal Key"
#   deletion_window_in_days = 10
#   multi_region = true
# }

module "primary-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  # providers = {
  #   aws = aws.primary-region
  # }
  
  # insert the 23 required variables here
  name = "${var.prefix}-primaryClusterVpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    Owner = "rryjewski"
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

# module "accelerator_aws_vault" {
#   # source  = "app.terraform.io/brightblueray/vault-cluster/aws"
#   # version = "0.1.0"
#   source = "./accelerator-aws-vault/"
#   # insert required variables here
#   # network = data.terraform_remote_state.vault-infra.outputs.primary-vpc-id
#   # region = data.terraform_remote_state.vault-infra.outputs.primary-vpc-region
#   # subnetworks = data.terraform_remote_state.vault-infra.outputs.primary-vpc-subnetworks
#   network = module.primary-vpc.vpc_id
#   region = var.primary-vpc-region
#   subnetworks = module.primary-vpc.public_subnets
#   vault_private_key_secret = "arn:aws:secretsmanager:us-east-2:711129375688:secret:certificate_private_key-1MnUsq"
#   vault_signed_cert_secret = "arn:aws:secretsmanager:us-east-2:711129375688:secret:signed_certificate-3DirYq"
#   vault_ca_bundle_secret = "arn:aws:secretsmanager:us-east-2:711129375688:secret:ca_bundle-Wa3zkc"
#   aws_kms_key_id = aws_kms_key.rryjewski-vault-unseal.key_id
# }