
module "controller" {
  source      = "./01_controller"
  private_key = var.private_key
  public_key  = var.public_key
  aws_region  = var.aws_region
}

module "gateways" {
  source         = "./02_gateways"
  controller_dns = module.controller.controller_dns
  aws_region     = var.aws_region
}
