
variable "gateway_instance_type" {
  description = "aws instance size for the Controller. See https://sdphelp.cyxtera.com/adminguide/v5.0/instance-sizing.html"
  default     = "m4.xlarge"
}


variable "controller_dns" {
  default = "ec2-54-83-163-128.compute-1.amazonaws.com"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

locals {
  service_name = "appgate"
  owner        = "dln"

  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
