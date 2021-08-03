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
    --no-registration \
    --hostname "$PUBLIC_HOSTNAME" \
    --admin-hostname "$PUBLIC_HOSTNAME" \
    --admin-password ${var.admin_login_password}  >> /home/cz/seed.json
EOF
}
