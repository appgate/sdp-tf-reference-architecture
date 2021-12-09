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

  connection {
    type        = "ssh"
    user        = "cz"
    timeout     = "25m"
    private_key = file(var.private_key)
    host        = aws_instance.appgate_controller.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      # Just keep provisioning the instance until the controller comes online;
      # once the controller response on the web request, we will assume the controller is online
      # alternative we could do "sudo cz-config status | jq -r .status" but that requires sudo privileges
      "while true; do curl --connect-timeout 5 --silent --fail -LI --insecure https://0.0.0.0:8443/ui -o /dev/null && exit 0; done"
    ]
  }
}

