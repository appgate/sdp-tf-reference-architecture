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

data "aws_security_group" "appgate_security_group" {
  tags = var.common_tags
}


data "aws_subnet" "appgate_appliance_subnet" {
  tags = var.common_tags
}
