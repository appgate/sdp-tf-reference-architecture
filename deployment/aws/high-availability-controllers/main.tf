
module "aws_resources" {
  source                   = "./aws"
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
  depends_on = [module.aws_resources]
  content = jsonencode({
    "appgate_url"            = format("https://%s:8443/admin", module.aws_resources.controller_dns)
    "appgate_username"       = "admin"
    "appgate_password"       = var.admin_login_password
    "appgate_provider"       = "local"
    "appgate_client_version" = 15
  })
  filename = "./appgateprovider.config.json"
}


module "appgate" {
  source                   = "./appgate"
  appgate_config_file      = local_file.appgateconfig.filename
  private_key              = var.private_key
  aws_region               = var.aws_region
  appgate_ami              = var.appgate_ami
  controller_instance_type = var.controller_instance_type
  subnet_id                = module.aws_resources.first_controller_subnet_id
  security_group           = module.aws_resources.first_controller_security_group
  aws_key_pair_name        = module.aws_resources.first_controller_key_pair
  common_tags              = local.common_tags
}
