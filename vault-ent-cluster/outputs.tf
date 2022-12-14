# output "vpc_id" {
#   value = module.vault-ent-starter_example_prereqs_quickstart.vpc_id
# }

# output "private_subnet_ids" {
#   value = module.vault-ent-starter_example_prereqs_quickstart.private_subnet_ids
# }

# output "secrets_manager_arn" {
#   value = module.vault-ent-starter_example_prereqs_quickstart.secrets_manager_arn
# }

# output "leader_tls_servername" {
#   value = module.vault-ent-starter_example_prereqs_quickstart.leader_tls_servername
# }

# output "lb_certificate_arn" {
#   value = module.vault-ent-starter.lb_certificate_arn
# }

output "ingress_nlb_name" {
  value = aws_lb.ingress_nlb.dns_name
}

output "vault_lb_dns_name" {
  value = module.vault-ent-starter.vault_lb_dns_name
}