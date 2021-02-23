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
locals {
  controller_user_data = <<-EOF
#!/bin/bash
PUBLIC_HOSTNAME=`curl --silent http://169.254.169.254/latest/meta-data/public-hostname`
# seed the first controller, and enable admin interface on :8443
cz-seed \
    --password cz cz \
    --dhcp-ipv4 eth0 \
    --enable-logserver \
    --no-registration \
    --hostname "$PUBLIC_HOSTNAME" \
    | jq '.remote.adminInterface.hostname = .remote.peerInterface.hostname | .remote.adminInterface.allowSources = .remote.peerInterface.allowSources' >> /home/cz/seed.json

EOF
}
resource "aws_instance" "appgate_controller" {
  ami = var.appgate_ami != "" ? var.appgate_ami : data.aws_ami.appgate.id

  # https://sdphelp.appgate.com/adminguide/v5.3/instance-sizing.html
  instance_type = var.controller_instance_type
  subnet_id     = var.subnet_id != "" ? var.subnet_id : aws_subnet.appgate_appliance_subnet.id
  vpc_security_group_ids = [
    var.security_group != "" ? var.security_group : aws_security_group.appgate_security_group.id
  ]
  key_name                    = var.aws_key_pair_name != "" ? var.aws_key_pair_name : aws_key_pair.deployer.key_name
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

  connection {
    type        = "ssh"
    user        = "cz"
    timeout     = "25m"
    private_key = file(var.private_key)
    host        = aws_instance.appgate_controller.public_ip
  }

  # https://sdphelp.appgate.com/adminguide/v5.3/appliance-installation.html
  user_data_base64 = base64encode(local.controller_user_data)

  tags = merge(var.common_tags, {
    Name = "controller-appgate"
  })
}

