
data "aws_security_group" "appgate_security_group" {
  tags = local.common_tags
}

data "aws_subnet" "appgate_appliance_subnet" {
  tags = local.common_tags
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
