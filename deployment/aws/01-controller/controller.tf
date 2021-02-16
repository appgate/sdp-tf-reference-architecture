provider "aws" {
  region = var.aws_region
}


resource "aws_instance" "appgate_controller" {
  ami = var.appgate_ami
  # https://sdphelp.cyxtera.com/adminguide/v5.0/instance-sizing.html
  instance_type               = var.controller_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group]
  key_name                    = var.aws_key_pair_name
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

  # https://sdphelp.cyxtera.com/adminguide/v5.0/appliance-installation.html
  provisioner "remote-exec" {
    inline = [
      # https://sdphelp.cyxtera.com/adminguide/v5.0/new-appliance.html?anchor=manual-seeding
      "cz-seed --output /home/cz/seed.json --password cz cz --dhcp-ipv4 eth0 --enable-logserver --no-registration --hostname ${self.public_dns}"
    ]
  }

  tags = merge(var.common_tags, {
    Name = "controller-appgate"
  })
}
