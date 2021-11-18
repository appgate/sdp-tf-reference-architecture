provider "aws" {
  region = var.aws_region
}

locals {
  controller_user_data = <<-EOF
#!/bin/bash
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
PUBLIC_HOSTNAME=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN"  http://169.254.169.254/latest/meta-data/public-hostname`

# Initiate the first controller with cz-seed to setup basic network configuration
# TODO change the default CLI login from cz / cz to your own.
cz-seed \
    --password cz cz \
    --dhcp-ipv4 eth0 \
    --enable-logserver \
    --hostname "$PUBLIC_HOSTNAME" \
    --admin-hostname "$PUBLIC_HOSTNAME" \
    --admin-password ${var.admin_login_password}  >> /home/cz/seed.json
EOF
}


resource "aws_instance" "first_controller" {
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
    Name = "first-controller-appgate"
  })

  connection {
    type        = "ssh"
    user        = "cz"
    timeout     = "25m"
    private_key = file(var.private_key)
    host        = aws_instance.first_controller.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      # Just keep provisioning the instance until the controller comes online;
      # once the controller response on the web request, we will asume the controller is online
      # alternative we could do "sudo cz-config status | jq -r .status" but that requires sudo privileges
      "while true; do curl --connect-timeout 5 --silent --fail -LI --insecure https://0.0.0.0:8443/ui -o /dev/null && exit 0; done"
    ]
  }
  provisioner "local-exec" {
    command = "check_status=true; while($check_status); do status=$(curl -X POST -k -s -o /dev/null -I -w %%{http_code} https://${aws_instance.first_controller.public_dns}:8443/admin/login); if [[ \"$status\" -ne 406 ]]; then check_status=true; sleep 3; else check_status=false; fi; done; sleep 60"
  }
}
