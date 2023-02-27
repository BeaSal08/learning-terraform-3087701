data "aws_ami" "amazon_ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20220606.1-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_ami.id
  instance_type = "t2.micro"
  availability_zone = "us-east-1e"

  tags = {
    Name = "HelloWorldBea"
    Project = "Terraform Learning"
  }
}
