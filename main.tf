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

module "app_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev" # Name of the vpc that we are creating
  cidr = "10.0.0.0/16"

  azs             = ["us-west-1a", "us-west-2b", "us-west-1c"]  # Availability zones
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "app" {   # resource definition: what we want, the recourse name as we refer to it in terraform code
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type # Variable defined by us

  vpc_security_group_ids = [aws_security_group.app.id]

  subnet_id = module.blog_vpc.public_subnets[0]

  tags = {
    Name = "HelloWorld" # How it appears on AWS
  }
}

module "app_sg" {       # taken from https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name = "app_new"

  vpc_id = module.blog_vpc.vpc_id 
  
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

# Security group without module
# resource "aws_security_group" "app" {
#   name = "app"
#   description = "Allow http and https in. Allow everything out."
#   
#   vpc_id = data.aws_vpc.default.id 
# }
# 
# resource "aws_security_group_rule" "app_http_in" {
#   type        = "ingress"
#   from_port   = 80
#   to_port     = 80
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# 
#   security_group_id = aws_security_group.app.id
# }
# 
# resource "aws_security_group_rule" "app_https_in" {
#   type        = "ingress"
#   from_port   = 443
#   to_port     = 443
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# 
#   security_group_id = aws_security_group.app.id
# }
# 
# resource "aws_security_group_rule" "app_everything_out" {
#   type        = "egress"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1" # allows all protocols
#   cidr_blocks = ["0.0.0.0/0"]
# 
#   security_group_id = aws_security_group.app.id
# }