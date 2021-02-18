# Creates appgate controller and some boilerplate networking for the example.
# Disable this module if you only want the appgate gateway with autoscaling.
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
  common_tags              = local.common_tags
}

# Gateway module creates the appgate gateways in an aws autoscaling group.
# Thse userdata includes step to join and leave the collective. 
module "gateways" {
  source                = "./gateways"
  controller_dns        = module.controller.controller_dns
  aws_region            = var.aws_region
  gateway_instance_type = var.gateway_instance_type
  appgate_ami           = var.appgate_ami
  security_group        = var.security_group
  common_tags           = local.common_tags
  subnet_id             = var.subnet_id
  aws_key_pair_name     = var.aws_key_pair_name
}


output "controller_ui" {
  value = format("https://%s:8443", module.controller.controller_dns)
}
