variable "prefix" {
  type        = string
  description = "prefix for searching AWS console"
  default     = "rryjewski"
}

variable "vpc-primary-region" {
  type        = string
  description = "Region for the primary VPC"
  default     = "us-east-2"
}

variable "vpc-hadr-region" {
  type        = string
  description = "Region for the hadr VPC"
  default     = "us-east-1"
}

variable "vpc-primary-pub-subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "vpc-primary-priv-subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc-primary-azs" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
