data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.security-group.security_group_id]

  tags = {
    Name = "HelloWorldBea"
    Project = "Terraform Learning"
  }
}

# Security Group via module
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"
  name    = "helloworld-sg-module"

  vpc_id = data.aws_vpc.default.id

  ingress_rules = ["http-80-tcp"]
  ingress_cidr_blocks = ["161.69.102.20/32"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

}