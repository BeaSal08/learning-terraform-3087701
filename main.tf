resource "aws_instance" "web" {
  ami           = ami-03c3fde85049dd22b
  instance_type = "t2.micro"
  availability_zone = "us-east-1e"

  tags = {
    Name = "HelloWorldBea"
    Project = "Terraform Learning"
  }
}
