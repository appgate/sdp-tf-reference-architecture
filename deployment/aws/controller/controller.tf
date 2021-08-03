provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "appgate_controller" {
  ami = var.appgate_ami != "" ? var.appgate_ami : data.aws_ami.appgate_ami.id

  # https://sdphelp.appgate.com/adminguide/v5.4/instance-sizing.html
  instance_type = var.controller_instance_type
  subnet_id     = var.subnet_id == "" ? aws_subnet.appgate_appliance_subnet[0].id : var.subnet_id
  vpc_security_group_ids = [
    var.security_group == "" ? aws_security_group.appgate_security_group[0].id : var.security_group
  ]
  key_name                    = var.aws_key_pair_name == "" ? aws_key_pair.deployer[0].key_name : var.aws_key_pair_name
  associate_public_ip_address = true


  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  ebs_block_device {
    volume_type = "gp2"
    volume_size = 20
    device_name = "/dev/xvdb"
  }

  # https://sdphelp.appgate.com/adminguide/v5.4/appliance-installation.html
  user_data_base64 = base64encode(local.controller_user_data)

  tags = merge(var.common_tags, {
    Name = "controller-appgate"
  })
}

