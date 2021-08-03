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
  type        = string
  description = "Prefer to ignore: Consider using the appgate_version + licensing_type parameters to locate your AMI. Only specify if you want to override AMI looking."
  default     = ""
}

variable "licensing_type" {
  type        = string
  description = "Valid Values: byol or licensed. Whether or not to use a bring your own license or prelicensed AMI."
  default     = "byol"
  validation {
    condition     = lower(var.licensing_type) == "byol" || lower(var.licensing_type) == "licensed"
    error_message = "ERROR Valid value options: byol, licensed."
  }
}

variable "appgate_version" {
  type        = string
  default     = "5.4.1" # latest
  description = "semantic version of the version of appgate you want to install. will search for an AMI matching this semver"
  validation {
    # Regex for valid semver from https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    condition = can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$",
    var.appgate_version))
    error_message = "ERROR must be a semantic version (string)."
  }
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
  description = "aws instance size for the Controller. See https://sdphelp.appgate.com/adminguide/v5.4/instance-sizing.html"
  default     = "m4.xlarge"
}
variable "controller_instance_type" {
  description = "aws instance size for the Controller. See https://sdphelp.appgate.com/adminguide/v5.4/instance-sizing.html"
  default     = "m4.xlarge"
}
variable "internet_gateway_id" {}
variable "vpc_id" {}
variable "appliance_cidr_block" {}
variable "ingress_cidr_blocks" {}
