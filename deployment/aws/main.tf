
module "controller" {
  source                   = "./01-controller"
  private_key              = var.private_key
  controller_instance_type = var.controller_instance_type
  aws_region               = var.aws_region
  appgate_ami              = data.aws_ami.appgate.id
  subnet_id                = aws_subnet.appgate_appliance_subnet.id
  security_group           = aws_security_group.appgate_security_group.id
  aws_key_pair_name        = aws_key_pair.deployer.key_name
  common_tags              = local.common_tags
}

module "gateways" {
  source                = "./02-gateways"
  controller_dns        = module.controller.controller_dns
  aws_region            = var.aws_region
  gateway_instance_type = var.gateway_instance_type
  appgate_ami           = data.aws_ami.appgate.id
  security_group        = aws_security_group.appgate_security_group.id
  common_tags           = local.common_tags
  subnet_id             = aws_subnet.appgate_appliance_subnet.id
  aws_key_pair_name     = aws_key_pair.deployer.key_name
}


provider "aws" {
  region = var.aws_region
}

data "aws_ami" "appgate" {
  most_recent = true

  filter {
    name   = "name"
    values = ["AppGate-SDP-5.3.2-Paid-d039c81b-2ac0-4798-98c7-afcf6226c4f7-ami-0fef14b943f691703.4"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

resource "aws_subnet" "appgate_appliance_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.appliance_cidr_block

  assign_ipv6_address_on_creation = false

  tags = local.common_tags
}

resource "aws_security_group" "appgate_security_group" {
  description = "Security group used by Appgate."
  vpc_id      = var.vpc_id

  # Allow all protocols
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      var.appliance_cidr_block,
      "212.16.176.132/32",
      "62.63.239.36/32"
    ]
    ipv6_cidr_blocks = [
      "2a01:2b0:302c::/48"
    ]

  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      var.appliance_cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags = local.common_tags
}

resource "aws_route_table_association" "appgate_route_table_assoication" {
  subnet_id      = aws_subnet.appgate_appliance_subnet.id
  route_table_id = aws_route_table.appgate_route_table.id
}

data "aws_internet_gateway" "selected" {
  internet_gateway_id = var.internet_gateway_id
}

resource "aws_route_table" "appgate_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.selected.id
  }
  tags = local.common_tags
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key)
  tags       = local.common_tags
}
