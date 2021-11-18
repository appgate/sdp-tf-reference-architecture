
provider "aws" {
  region = var.aws_region
}
resource "aws_instance" "second_controller" {
  ami = var.appgate_ami

  # https://sdphelp.appgate.com/adminguide/v5.4/instance-sizing.html
  instance_type = var.controller_instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [
    var.security_group
  ]
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


  tags = merge(var.common_tags, {
    Name = "second-controller-appgate"
  })
}

