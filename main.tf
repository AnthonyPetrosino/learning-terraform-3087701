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

resource "aws_instance" "app" {   # resource definition: what we want, the recourse name as we refer to it in terraform code
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type # Variable defined by us

  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name = "HelloWorld" # How it appears on AWS
  }
}

module "app_sq" {       # taken from https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name = "app_new"

  vpc_security_group_ids = [module.app_sg.security_group_id] 
  
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = [all-all]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "app" {
  name = "app"
  description = "Allow http and https in. Allow everything out."
  
  vpc_id = data.aws_vpc.default.id 
}

resource "aws_security_group_rule" "app_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1" # allows all protocols
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app.id
}