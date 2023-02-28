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

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc-bea"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Project = "Cap Build"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name = "blog"

  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = module.alb.target_group_arns
  security_groups     = [module.security-group.security_group_id]
  instance_type       = var.instance_type
  image_id            = data.aws_ami.app_ami.id
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security-group.security_group_id]

  target_groups = [
    {
      name_prefix      = "tbea-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security-group.security_group_id]

  tags = {
    Name = "HelloWorldBea"
    Project = "Cap Build"
  }
}

# Security Group via module

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id  = module.vpc.vpc_id
  name    = "helloworld-sg-module"
  ingress_rules = ["http-80-tcp"]
  ingress_cidr_blocks = ["112.198.36.8/32"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

      tags = {
    Project = "Cap Build"
  }
}