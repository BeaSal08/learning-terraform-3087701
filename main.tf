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


# resource "aws_instance" "web" {
#   ami           = data.aws_ami.app_ami.id
#   instance_type = var.instance_type
# 
#   vpc_security_group_ids = [aws_security_group.web.id]
# 
#   tags = {
#     Name = "HelloWorldBea"
#     Project = "Terraform Learning"
#   }
# }
# 
# 
# Security Group
# resource "aws_security_group" "web" {
#   name        = "helloworld-sg"
#   description = "Allows http IN. Allows everything OUT"
# 
#   vpc_id = data.aws_vpc.default.id
# }
# 
# Inbound Security Group Rule
# resource "aws_security_group_rule" "web_http_in" {
#   type = "ingress"
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = ["161.69.102.20/32"]
# 
#   security_group_id = aws_security_group.web.id
# }
# 
# Outbound Security Group Rule
# resource "aws_security_group_rule" "web_all_out" {
#   type = "egress"
#   from_port = 0
#   to_port = 0
#   protocol = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# 
#   security_group_id = aws_security_group.web.id
# }