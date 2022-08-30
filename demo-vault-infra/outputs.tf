output "vpc-primary-region" {
  value = var.vpc-primary-region
}

# output "vpc-hadr-region" {
#   value = var.vpc-hadr-region
# }

output "vpc-primary-id" {
  value = module.vpc-primary.vpc_id
}

output "vpc-primary-subnets-pub" {
  value = module.vpc-primary.public_subnets
}

output "vpc-primary-subnets-priv" {
  value = module.vpc-primary.private_subnets
}

# output "aws-kms-key-id" {
#   value = aws_kms_key.rryjewski-vault-unseal.key_id
# }

output "lb_certificate_arn" {
  description = "ARN of ACM cert to use with Vault LB listener"
  value       = module.secrets.lb_certificate_arn
}

output "leader_tls_servername" {
  description = "Shared SAN that will be given to the Vault nodes configuration for use as leader_tls_servername"
  value       = module.secrets.leader_tls_servername
}

output "secrets_manager_arn" {
  description = "ARN of secrets_manager secret"
  value       = module.secrets.secrets_manager_arn
}