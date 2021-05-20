terraform {
  required_providers {
    appgatesdp = {
      source  = "appgate/appgatesdp"
      version = "0.5.0"
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
  username = "admin"
  password = "admin"
  url      = "https://${var.controller_dns}:8443/admin"
  provider = "local"
  insecure = true
}

data "appgatesdp_certificate_authority" "ca" {
  pem = true
}

data "appgatesdp_site" "default_site" {
  site_name = "Default site"
}

resource "appgatesdp_administrative_role" "test_administrative_role" {
  name = "tf-autoscale-gateway-role"
  tags = local.appgate_tags
  privileges {
    type   = "View"
    target = "Appliance"
    scope {
      tags = local.appgate_tags
    }
  }
  privileges {
    type   = "Delete"
    target = "Appliance"
    scope {
      tags = local.appgate_tags
    }
  }
  privileges {
    type   = "Export"
    target = "Appliance"
    scope {
      tags = local.appgate_tags
    }
  }
  privileges {
    type         = "Create"
    target       = "Appliance"
    default_tags = local.appgate_tags
  }
  privileges {
    type   = "View"
    target = "Site"
    scope {
      ids = [
        data.appgatesdp_site.default_site.id
      ]
    }
  }
}

data "appgatesdp_identity_provider" "local_identity_provider" {
  # builtin resource
  identity_provider_name = "local"
}

# The local user that we will use during autoscaling of the gateway(s).
# Warning: The following is only an example. Never check sensitive values like
# usernames and passwords into source control.
# https://learn.hashicorp.com/tutorials/terraform/sensitive-variables
resource "appgatesdp_local_user" "gateway_api_user" {
  name     = "gateway_autoscale"
  password = "aws_appgate"

  notes      = "API credentials for the autoscale user."
  first_name = "GatewayAWSUser"
  last_name  = "aws"
  tags       = local.appgate_tags
}

# this is just for demo purpose. to store API credentials to we use for autoscaling in the gateways userdata.
# Warning: The following is only an example. Never check sensitive values like
# usernames and passwords into source control.
# https://learn.hashicorp.com/tutorials/terraform/sensitive-variables
resource "aws_secretsmanager_secret" "appgate_api_credentials" {
  name        = "appgate-api-credentials-3"
  description = "Appgate API credentials. Used by autoscaled gateways."
  tags        = var.common_tags
}

resource "aws_secretsmanager_secret_version" "appgate_api_password" {
  secret_id     = aws_secretsmanager_secret.appgate_api_credentials.id
  secret_string = appgatesdp_local_user.gateway_api_user.password
}


resource "appgatesdp_policy" "api_gw_user_policy" {
  name     = "gateway api user policy"
  notes    = "Policy for gateway api user, used during autoscaling."
  tags     = local.appgate_tags
  disabled = false
  administrative_roles = [
    appgatesdp_administrative_role.test_administrative_role.id
  ]
  expression = <<-EOF
var result = false;
/*claims.user.ag.identityProviderId*/
if(claims.user.ag && claims.user.ag.identityProviderId === "${data.appgatesdp_identity_provider.local_identity_provider.id}"){
     result = true;
} else {
     return false;
}
/*claims.user.username*/
if(claims.user.username === "${appgatesdp_local_user.gateway_api_user.name}") {
    result = true;
} else {
    return false;
}
return result;
EOF
}



# The appliance gateway will be used as a template for all the other auto-scaled gateways.
resource "appgatesdp_appliance" "template_gateway" {
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

  tags  = concat(local.appgate_tags, ["template"])
  notes = "Autoscaled gateway, defined in terraform."
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
