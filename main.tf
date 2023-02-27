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

  vpc_security_group_ids = ["aws_security_group.web.id"]

  tags = {
    Name = "HelloWorldBea"
    Project = "Terraform Learning"
  }
}

# Security Group
resource "aws_security_group" "web" {
  name        = "helloworld-sg"
  description = "Allows http IN. Allows everything OUT"

  vpc_id = data.aws_vpc.default.id
}

# Inbound Security Group Rule
resource "aws_security_group_rule" "web_http_in" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = tcp
  cidr_blocks = ["161.69.102.20/32"]

  aws_security_group_id = aws_security_group.web.id
}

# Outbound Security Group Rule
resource "aws_security_group_rule" "web_all_out" {
  type = "egress"
  from_port = 0
  to_port = "-1"
  protocol = tcp
  cidr_blocks = ["0.0.0.0/0"]

  aws_security_group_id = aws_security_group.web.id
}