data "aws_ami" "appgate_ami" {
  owners = ["679593333241"] # Appgate

  filter {
    name   = "name"
    values = ["*${var.appgate_version}*"]
  }

  # Product Codes
  # BYOL      2t5itl5x43ar3tljs7s2mu3rw
  # Licensed  2oiadaeqo2k6kdw1pgflzxkfd

  filter {
    name = "product-code"
    values = [lower(var.licensing_type) == "byol" ?
      "2t5itl5x43ar3tljs7s2mu3rw" : # byol
      "2oiadaeqo2k6kdw1pgflzxkfd"   # licensed
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