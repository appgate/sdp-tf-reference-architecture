

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




locals {
  service_name = "appgate"
  owner        = "dln"

  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
