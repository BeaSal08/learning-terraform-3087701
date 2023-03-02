data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] # Bitnami
}

module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
        Project = "Cap Build"
    Environment = var.environment.name
  }
}

module "autoscaling" {

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name = "auto"

  min_size            = var.asg_min
  max_size            = var.asg_max
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
  ingress_cidr_blocks = ["161.69.102.20/32"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

      tags = {
    Project = "Cap Build"
  }
}