variable "prefix" {
  type        = string
  description = "prefix for searching AWS console"
  default     = "rryjewski"
}

variable "primary-vault-region" {
  type        = string
  description = "Region for the primary VPC"
  default     = "us-east-2"
}

variable "hadr-vault-region" {
  type        = string
  description = "Region for the hadr VPC"
  default     = "us-east-1"
}

variable "vault-license" {
  type = string
}