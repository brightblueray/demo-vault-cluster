terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    hcp = {
      source = "hashicorp/hcp"
    }
    # local = {
    #   source = "hashicorp/local"
    # }
  }
  cloud {
    organization = "brightblueray"
    workspaces {
      name = "demo-vault-cluster"
    }
  }
}

provider "local" {
  # Configuration options
}

// Providers
provider "hcp" {}

provider "aws" {
  alias  = "primary"
  region = var.primary-vault-region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Purpose     = "demo"
      Owner       = "rryjewski"
    }
  }
}

data "hcp_packer_image" "ubuntu-vault-img" {
  bucket_name    = "ubuntu-focal-base"
  cloud_provider = "aws"
  channel        = "dev"
  region         = "us-east-2"
}

# resource "local_sensitive_file" "vault-lic" {
#     content  = "foo!"
#     filename = "vault.hclic"
# }

// Vault Pre-reqs
module "vault-ent-starter_example_prereqs_quickstart" {
  source  = "hashicorp/vault-ent-starter/aws//examples/prereqs_quickstart"
  version = "0.2.1"
  # insert the 1 required variable here
  resource_name_prefix = "rryjewski"
  aws_region = "us-east-2"
  azs = [ "us-east-2a", "us-east-2b", "us-east-2c" ]
}

// Build Vault Cluster
module "vault-ent-starter" {
  source  = "hashicorp/vault-ent-starter/aws"
  version = "0.2.1"
  providers = {
    aws = aws.primary
  }

  # prefix for tagging/naming AWS resources
  resource_name_prefix = "test"

  vpc_id                = module.vault-ent-starter_example_prereqs_quickstart.vpc_id
  private_subnet_ids    = module.vault-ent-starter_example_prereqs_quickstart.private_subnet_ids
  secrets_manager_arn   = module.vault-ent-starter_example_prereqs_quickstart.secrets_manager_arn
  leader_tls_servername = module.vault-ent-starter_example_prereqs_quickstart.leader_tls_servername
  lb_certificate_arn    = module.vault-ent-starter_example_prereqs_quickstart.lb_certificate_arn

  vault_license_filepath = "${path.module}/vault.hclic"
}
