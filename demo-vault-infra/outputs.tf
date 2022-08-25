output "primary-vpc-region" {
  value = var.primary-vpc-region
}

output "hadr-vpc-region" {
  value = var.hadr-vpc-region
}

output "primary-vpc-id" {
  value = module.primary-vpc.vpc_id
}

output "primary-vpc-subnetworks" {
  value = module.primary-vpc.public_subnets
}

output "aws-kms-key-id" {
  value = aws_kms_key.rryjewski-vault-unseal.key_id
}