module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "koffeeluv-vpc"
  cidr = "172.16.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24","172.16.8.0/24", "172.16.9.0/24", "172.16.10.0/24"]
  public_subnets  = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]

  enable_nat_gateway = true
#   enable_vpn_gateway = false
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "Allow SSH access to bastion hosts"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "SSH from anywhere"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self = false
      prefix_list_ids = []
      security_groups = []
    }
  ]

  egress = [
    {
      description      = "For all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = []
      security_groups = []

    }
  ]

  tags = {
    Name = "BastionSG"
  }
}

resource "aws_security_group" "AppSG" {
  name        = "AppSG"
  description = "Rules for the app servers"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "SSH from bastion"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = module.vpc.public_subnets_cidr_blocks
      ipv6_cidr_blocks = []
      self = false
      prefix_list_ids = []
      security_groups = []
    }
  ]

  egress = [
    {
      description      = "For all outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = []
      security_groups = []

    }
  ]

  tags = {
    Name = "AppSG"
  }
}


