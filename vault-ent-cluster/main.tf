terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    hcp = {
      source = "hashicorp/hcp"
    }
    local = {
      source = "hashicorp/local"
    }
  }
  cloud {
    organization = "brightblueray"
    workspaces {
      name = "vault-ent-cluster"
    }
  }
}


// Providers
provider "hcp" {}
provider "local" {}
provider "aws" {
  alias  = "primary"
  region = var.primary-vault-region
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Purpose     = "Vault_Enterprise_Demo"
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

data "terraform_remote_state" "demo-vault-infra" {
  backend = "remote"

  config = {
    organization = "brightblueray"
    workspaces = {
      name = "demo-vault-infra"
    }
  }
}

resource "local_sensitive_file" "vault-lic" {
  content  = var.vault-license
  filename = "${path.module}/vault.hclic"
}

// Build Vault Cluster
module "vault-ent-starter" {
  source  = "hashicorp/vault-ent-starter/aws"
  version = "0.2.1"
  providers = {
    aws = aws.primary
  }
  depends_on = [
    local_sensitive_file.vault-lic
  ]

  # prefix for tagging/naming AWS resources
  resource_name_prefix = var.prefix

  vpc_id                = data.terraform_remote_state.demo-vault-infra.outputs.vpc-primary-id
  private_subnet_ids    = data.terraform_remote_state.demo-vault-infra.outputs.vpc-primary-subnets-priv
  secrets_manager_arn   = data.terraform_remote_state.demo-vault-infra.outputs.secrets_manager_arn
  leader_tls_servername = data.terraform_remote_state.demo-vault-infra.outputs.leader_tls_servername
  lb_certificate_arn    = data.terraform_remote_state.demo-vault-infra.outputs.lb_certificate_arn

  allowed_inbound_cidrs_lb  = ["0.0.0.0/0"]
  allowed_inbound_cidrs_ssh = ["0.0.0.0/0"]
  key_name                  = "rryjewski"
  instance_type             = "m5.large"
  vault_version             = "1.11.2"

  vault_license_filepath = "${path.module}/vault.hclic"
}

// Create Ingress NLB
resource "aws_lb" "ingress_nlb" {
  provider = aws.primary
  name = "${var.prefix}-tf-nlb-ingress"
  internal = false
  load_balancer_type = "network"
  subnets = data.terraform_remote_state.demo-vault-infra.outputs.vpc-primary-subnets-pub
}

resource "aws_lb_target_group" "alb-vault-tg" {
  provider = aws.primary
  name = "${var.prefix}-alb-vault-tg"
  target_type = "alb"
  port = 8200
  protocol = "TCP"
  vpc_id = data.terraform_remote_state.demo-vault-infra.outputs.vpc-primary-id
}

resource "aws_lb_listener" "vault_listener" {
  provider = aws.primary
  load_balancer_arn = aws_lb.ingress_nlb.arn
  port = 8200
  protocol = "TCP"
  # certificate_arn = data.terraform_remote_state.demo-vault-infra.outputs.lb_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.alb-vault-tg.arn
    type = "forward"
  }
}

resource "aws_lb_target_group_attachment" "target" {
  provider = aws.primary
  target_group_arn = aws_lb_target_group.alb-vault-tg.arn
  target_id = module.vault-ent-starter.vault_lb_arn
}