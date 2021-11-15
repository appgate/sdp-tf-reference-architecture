module "controller" {
  source                   = "./controller"
  private_key              = var.private_key
  public_key               = var.public_key
  controller_instance_type = var.controller_instance_type
  aws_region               = var.aws_region
  appgate_ami              = var.appgate_ami
  subnet_id                = var.subnet_id
  security_group           = var.security_group
  aws_key_pair_name        = var.aws_key_pair_name
  internet_gateway_id      = var.internet_gateway_id
  vpc_id                   = var.vpc_id
  appliance_cidr_block     = var.appliance_cidr_block
  ingress_cidr_blocks      = var.ingress_cidr_blocks
  common_tags              = local.common_tags
  admin_login_password     = var.admin_login_password
}

resource "local_file" "appgateconfig" {
  # HACK: depends_on for the appgatesdp provider
  # Passing provider configuration value via a local_file
  depends_on = [module.controller]
  sensitive_content = jsonencode({
    "appgate_url"            = format("https://%s:8443/admin", module.controller.controller_dns)
    "appgate_username"       = "admin"
    "appgate_password"       = var.admin_login_password
    "appgate_provider"       = "local"
    "appgate_client_version" = 15
    "appgate_insecure"       = true
  })
  filename = "./appgateprovider.config.json"
}

module "gateways" {
  source                     = "./gateways"
  appgate_config_file        = local_file.appgateconfig.filename
  controller_dns             = module.controller.controller_dns
  aws_region                 = var.aws_region
  gateway_instance_type      = var.gateway_instance_type
  appgate_ami                = var.appgate_ami
  security_group             = var.security_group
  common_tags                = local.common_tags
  controller_subnet          = module.controller.controller_subnet
  aws_key_pair_name          = module.controller.key_name
  controller_security_groups = module.controller.controller_security_groups
}
