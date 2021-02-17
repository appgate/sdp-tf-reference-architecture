variable "private_key" {
  description = "Path to SSH private key that is used with key_name."
}
variable "public_key" {
  description = "Path to the public key"
}
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "appgate_ami" {
  default = ""
}
variable "subnet_id" {
  default = ""
}
variable "security_group" {
  default = ""
}
variable "aws_key_pair_name" {
  default = ""
}

locals {
  service_name = "appgate"
  owner        = "dln"

  # Common tags to be assigned to all aws resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

variable "gateway_instance_type" {
  description = "aws instance size for the Controller. See https://sdphelp.appgate.com/adminguide/v5.3/instance-sizing.html"
  default     = "m4.xlarge"
}
variable "controller_instance_type" {
  description = "aws instance size for the Controller. See https://sdphelp.appgate.com/adminguide/v5.3/instance-sizing.html"
  default     = "m4.xlarge"
}
