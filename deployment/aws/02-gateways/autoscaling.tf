terraform {
  required_providers {
    appgate = {
      source = "example.com/edu/appgate"
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

data "template_file" "user_data" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    site_id        = data.appgate_site.default_site.id
    pem            = data.appgate_certificate_authority.ca.certificate
    controller_dns = var.controller_dns
  }
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
    "api-created"
  ]
  notes = "hello world"
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



module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.8.0"

  name = "dln-gateway-with-ec2"

  create_lc = true
  lc_name   = "dln-lc"
  # create_lc            = false
  # launch_configuration = aws_launch_configuration.appgate_gateway_lc.name

  image_id                     = data.aws_ami.appgate.id
  instance_type                = "m4.large"
  security_groups              = [data.aws_security_group.appgate_security_group.id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true

  key_name = "deployer-key"

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
  asg_name                  = "dln-example-asg"
  vpc_zone_identifier       = [data.aws_subnet.appgate_appliance_subnet.id]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  # service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
    {
      key                 = "foo"
      value               = ""
      propagate_at_launch = true
    },
    {
      key                 = "bar"
      value               = ""
      propagate_at_launch = true
    }
  ]

  tags_as_map = local.common_tags
}
