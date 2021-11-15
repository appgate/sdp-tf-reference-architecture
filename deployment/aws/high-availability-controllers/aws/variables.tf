
variable "aws_region" {
  description = "AWS region to launch servers."
}
variable "appgate_ami" {
  type        = string
  description = "Prefer to ignore: Consider using the appgate_version + licensing_type parameters to locate your AMI. Only specify if you want to override AMI looking."

}
variable "subnet_id" {
  type        = string
  description = "if blank, will create a security group"
}
variable "security_group" {
  type        = string
  description = "if blank, will create a security group"
}

variable "controller_instance_type" {
  type        = string
  description = "Size of instance to deploy. Vendor recommends c5.xlarge"
}

variable "private_key" {
  type        = string
  description = "location of the private key you want to use to administer"
}
variable "public_key" {
  type        = string
  description = "location of the public key"
}
variable "aws_key_pair_name" {
  default     = ""
  description = "public key to set on ASG instances. If one does not previously exist, leave blank and fill in var.public_key"
}
variable "common_tags" {
  type    = map(any)
  default = {}
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
# Network related variables
variable "vpc_id" {}
variable "appliance_cidr_block" {}
variable "ingress_cidr_blocks" {
  type = list(any)
}
variable "internet_gateway_id" {}


variable "admin_login_password" {
  type      = string
  sensitive = true
}
