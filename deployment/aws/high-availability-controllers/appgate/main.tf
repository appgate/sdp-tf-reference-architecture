terraform {
  required_providers {
    appgatesdp = {
      source  = "appgate/appgatesdp"
      version = "0.8.2"
    }
  }
}

locals {
  appgate_tags = [
    "terraform",
    "aws-autoscale"
  ]
}

provider "appgatesdp" {
  config_path = var.appgate_config_file
  insecure    = true
}

data "appgatesdp_site" "default_site" {
  site_name = "Default site"
  depends_on = [
    aws_instance.second_controller
  ]
}

resource "appgatesdp_appliance" "second_controller" {
  lifecycle {
    ignore_changes = [
      # The following attributes will be defined and configured within
      # appgatesdp_appliance_controller_activation.activate_second_controller
      controller[0],
      admin_interface[0],

    ]
  }

  name     = replace(aws_instance.second_controller.public_dns, ".", "_")
  hostname = aws_instance.second_controller.public_dns
  tags     = local.appgate_tags
  client_interface {
    hostname = aws_instance.second_controller.public_dns

    allow_sources {
      address = "0.0.0.0"
      netmask = 0
    }
    allow_sources {
      address = "::"
      netmask = 0
    }
  }

  peer_interface {
    hostname = aws_instance.second_controller.public_dns
    allow_sources {
      address = "0.0.0.0"
      netmask = 0
    }
    allow_sources {
      address = "::"
      netmask = 0
    }
  }
  ntp {
    servers {
      hostname = "0.ubuntu.pool.ntp.org"
    }
    servers {
      hostname = "1.ubuntu.pool.ntp.org"
    }
    servers {
      hostname = "2.ubuntu.pool.ntp.org"
    }
    servers {
      hostname = "3.ubuntu.pool.ntp.org"
    }
  }

  notes = "Second controller, defined in terraform."
  site  = data.appgatesdp_site.default_site.id
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
  ssh_server {
    enabled                 = true
    port                    = 22
    password_authentication = true
    allow_sources {
      address = "0.0.0.0"
      netmask = 0
    }
    allow_sources {
      address = "::"
      netmask = 0
    }
  }
}

data "appgatesdp_appliance_seed" "second_controller_seed" {
  depends_on = [
    appgatesdp_appliance.second_controller,
  ]
  appliance_id   = appgatesdp_appliance.second_controller.id
  password       = "cz"
  latest_version = true
}


resource "null_resource" "seed_controller" {
  depends_on = [
    appgatesdp_appliance.second_controller,
  ]


  connection {
    type        = "ssh"
    user        = "cz"
    timeout     = "25m"
    private_key = file(var.private_key)
    host        = aws_instance.second_controller.public_dns
  }

  provisioner "local-exec" {
    command = "echo ${data.appgatesdp_appliance_seed.second_controller_seed.seed_file} > seed.b64"
  }
  provisioner "file" {
    source      = "seed.b64"
    destination = "/home/cz/seed.b64"
  }
  provisioner "remote-exec" {
    inline = [
      "cat seed.b64 | base64 -d  | jq .  >> seed.json",
      // wait for the seed to get picked up and initialized
      "sleep 120",
      "echo OK",
    ]
  }
}

resource "appgatesdp_appliance_controller_activation" "activate_second_controller" {
  depends_on = [
    appgatesdp_appliance.second_controller,
    null_resource.seed_controller,
  ]
  appliance_id = appgatesdp_appliance.second_controller.id
  controller {
    enabled = true
  }
  admin_interface {
    hostname   = aws_instance.second_controller.public_dns
    https_port = 8443
    https_ciphers = [
      "ECDHE-RSA-AES256-GCM-SHA384",
      "ECDHE-RSA-AES128-GCM-SHA256"
    ]
  }
}

