

# Create the networking resources
module "networking" {
    source = "./modules/networking"
}


# Create the data source to get the latest ubuntu ami
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    owners = ["099720109477"]
}


# Create an EC2 keypair from an existing key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCg3j15bhPB/zrEsam7qlCwPIlXBiAcRH57JCK8OapRQQew3VPq3jd1OQiqmiPETNBPj2PQmdpBYSL4B/xsqG4GuyGvImonnqXqxBvU55gkvjUgpBLPoEq8QkdAsdoSc4q6JWtNgPrP44LA2jqIiHiadaQ0wMMYAQmR+HgjR/bfyu7RGLUIPkP7Isp2Q/vy20XAKwOaFKPI5tNYSDpxYuQEQ7QZr7pDMqdyle5JVs1xWGuwv5S33OeCEa8Nf0j03d5Q8swH+zNCXZ1kih2EjJCdXVUswJz4teqb7NpEIM03yWOP2Um3e9xjQjHoIJnmnIUu9CaNaRnUBTrd6Bz9GK26qnyC/sq5XhMZ4AdbGy2JU8Y1FvPX2xk60B/KUPTRj4EK60hpSlbOvFr7t+PCMUQUaFaueTqxSfQxQDtcOBcHvowInd10+er51fUPe9r9QxDiK+74nLVinZeyrTGkKOVoTyyXi/XLwqFxm9OglBI/0yMG0PbUjnPuPkRW6WaK2hk= juzer@DESKTOP-7VB0UHQ"
}

# Create the bastion hosts in each public subnet
resource "aws_instance" "aws_instance_bastion_hosts"{
    for_each = toset(module.networking.vpc.public_subnets)
    # for_each = toset(module.networking.vpc.azs)
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    subnet_id = (each.value)
    # availability_zone = (each.value)
    security_groups = [ module.networking.BastionSG.id ]
    key_name = aws_key_pair.deployer.key_name
    tags = {
        Name = "Bastion Host"
    }
}

# Create a data source to get the subnet IDs for the app subnets
data "aws_subnet_ids" "app_subnet_ids" {
  vpc_id = module.networking.vpc.vpc_id
  filter {
    name   = "cidr-block"
    values = var.app_private_subnet_cidrs
  }
}

# Create the app server hosts in the 3 app subnets
resource "aws_instance" "aws_instance_app_servers"{
    for_each =  toset(data.aws_subnet_ids.app_subnet_ids.ids)
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    subnet_id = (each.value)
    security_groups = [ module.networking.AppSG.id ]
    key_name = aws_key_pair.deployer.key_name
    tags = {
        Name = "App Server"
    }
}