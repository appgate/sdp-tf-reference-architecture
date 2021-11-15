data "aws_ami" "appgate_ami" {
  owners      = ["679593333241"] # Appgate
  most_recent = true
  filter {
    name   = "name"
    values = ["*${var.appgate_version}*"]
  }

  # Product Codes
  # BYOL      2t5itl5x43ar3tljs7s2mu3rw
  # Licensed  cbse92jrh5o5yi82s7eub483b

  filter {
    name = "product-code"
    values = [lower(var.licensing_type) == "byol" ?
      "2t5itl5x43ar3tljs7s2mu3rw" : # byol
      "cbse92jrh5o5yi82s7eub483b"   # licensed
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_subnet" "appgate_appliance_subnet" {
  count      = var.subnet_id == "" ? 1 : 0
  vpc_id     = var.vpc_id
  cidr_block = var.appliance_cidr_block

  assign_ipv6_address_on_creation = false

  tags = var.common_tags
}

resource "aws_security_group" "appgate_security_group" {
  count       = var.security_group == "" ? 1 : 0
  description = "Security group used by Appgate."
  vpc_id      = var.vpc_id

  # Allow all protocols
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = concat(var.ingress_cidr_blocks, [var.appliance_cidr_block])
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
  tags = var.common_tags
}

resource "aws_route_table_association" "appgate_route_table_assoication" {
  subnet_id      = aws_subnet.appgate_appliance_subnet[0].id
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
  tags = var.common_tags
}


resource "aws_key_pair" "deployer" {
  count           = var.aws_key_pair_name == "" ? 1 : 0
  key_name_prefix = "appgate-demo-deployer-key"
  public_key      = file(var.public_key)
  tags            = var.common_tags
}
