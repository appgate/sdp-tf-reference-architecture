terraform {
  required_providers {
    appgate = {
      source = "appgate.com/appgate/appgate"
    }
  }
}
provider "aws" {
  region = var.aws_region
}
provider "appgate" {
  username = "admin"
  password = "admin"
  url      = "https://${var.controller_dns}:444/admin"
  provider = "local"
  insecure = true
}

data "appgate_certificate_authority" "ca" {
  pem = true
}
data "appgate_site" "default_site" {
  site_name = "Default site"
}



# The appliance gateway will be used as a template for all the other auto-scaled gateways.
resource "appgate_appliance" "template_gateway" {
  name     = replace("aws-gateway-template.devops", ".", "_")
  hostname = "aws-gateway-template.devops"

  client_interface {
    hostname       = "aws-gateway-template.devops"
    proxy_protocol = true
    https_port     = 8443
    dtls_port      = 443
    allow_sources {
      address = "0.0.0.0"
      netmask = 0
    }
    allow_sources {
      address = "::"
      netmask = 0
    }
    override_spa_mode = "TCP"
  }

  peer_interface {
    hostname   = "aws-gateway-template.devops"
    https_port = "444"

    allow_sources {
      address = "0.0.0.0"
      netmask = 0
    }
    allow_sources {
      address = "::"
      netmask = 0
    }
  }

  admin_interface {
    hostname = "aws-gateway-template.devops"
    https_ciphers = [
      "ECDHE-RSA-AES256-GCM-SHA384",
      "ECDHE-RSA-AES128-GCM-SHA256"
    ]
  }

  tags = [
    "terraform",
    "api-created",
    "autoscaled"
  ]
  notes = "Autoscaled gateway, defined in terraform."
  site  = data.appgate_site.default_site.id
  networking {
    nics {
      enabled = true
      name    = "eth0"
      ipv4 {
        dhcp {
          enabled = true
          dns     = true
          routers = true
          ntp     = true
        }
      }
    }
  }
  # https://sdphelp.appgate.com/adminguide/v5.1/about-appliances.html?anchor=gateway-a
  gateway {
    enabled = true
    vpn {
      weight = 100
      allow_destinations {
        address = "0.0.0.0"
        nic     = "eth0"
      }
    }
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    site_id        = data.appgate_site.default_site.id
    pem            = data.appgate_certificate_authority.ca.certificate
    controller_dns = var.controller_dns
    aws_region     = var.aws_region
    # aws_secret_arn = aws_secretsmanager_secret_version.appgate_api_password.arn
  }
}

module "autoscaling" {
  source        = "terraform-aws-modules/autoscaling/aws"
  version       = "3.8.0"
  name          = "appgate-gateway"
  create_lc     = true
  lc_name       = "appgate-tf-lc"
  image_id      = var.appgate_ami != "" ? var.appgate_ami : data.aws_ami.appgate.id
  instance_type = "m4.large"
  security_groups = [
    var.security_group != "" ? var.security_group : data.aws_security_group.appgate_security_group.id
  ]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = var.aws_key_pair_name != "" ? var.aws_key_pair_name : "deployer-key"

  user_data_base64 = base64encode(data.template_file.user_data.rendered)

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "50"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name = "appgate-asg"
  vpc_zone_identifier = [
    var.subnet_id != "" ? var.subnet_id : data.aws_subnet.appgate_appliance_subnet.id
  ]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags_as_map = var.common_tags
}
