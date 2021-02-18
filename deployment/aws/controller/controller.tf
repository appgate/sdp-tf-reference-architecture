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
  provisioner "file" {
    source      = "${path.module}/provision_controller.sh"
    destination = "/tmp/provision_controller.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision_controller.sh",
      "/tmp/provision_controller.sh",
    ]
  }

  tags = merge(var.common_tags, {
    Name = "controller-appgate"
  })
}

