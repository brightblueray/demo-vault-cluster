// Image for Bastion Host
data "hcp_packer_image" "ubuntu-vault-img" {
  bucket_name    = "ubuntu-focal-base"
  cloud_provider = "aws"
  channel        = "dev"
  region         = "us-east-2"
}

module "bastion_vault" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  providers = {
    aws = aws.primary-region
  }
  name = "bastion_vault"
  ami = data.hcp_packer_image.ubuntu-vault-img.cloud_image_id
  instance_type               = "t2.micro"
  key_name = "rryjewski"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id = module.vpc-primary.public_subnets[0]
  associate_public_ip_address = true
}


resource "aws_security_group" "bastion_sg" {
  provider = aws.primary-region
  name   = "bastion_sg"
  vpc_id = module.vpc-primary.vpc_id
}

resource "aws_security_group_rule" "ssh-in" {
  provider = aws.primary-region
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group_rule" "out-all" {
  provider = aws.primary-region
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

output "bastion-ip" {
  value = "ssh ubuntu@${module.bastion_vault.public_ip} -i ~/.ssh/rryjewski.pem"
}

output "bastion-hostname" {
  value = module.bastion_vault.public_dns
}