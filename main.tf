resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t2.micro"
  availability_zone = "us-east-1e"

  tags = {
    Name = "HelloWorldBea"
    Project = "Terraform Learning"
  }
}
