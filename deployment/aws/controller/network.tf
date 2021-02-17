resource "aws_subnet" "appgate_appliance_subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.appliance_cidr_block

  assign_ipv6_address_on_creation = false

  tags = var.common_tags
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
  tags = var.common_tags
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
  tags = var.common_tags
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key)
  tags       = var.common_tags
}
