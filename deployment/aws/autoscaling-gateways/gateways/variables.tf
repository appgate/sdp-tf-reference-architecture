variable "gateway_instance_type" {}
variable "appgate_config_file" {
  sensitive = true
}
variable "controller_subnet" {}
variable "controller_security_groups" {
  type = list(string)
}
variable "controller_dns" {}
variable "aws_region" {}
variable "security_group" {}
variable "common_tags" {}

variable "aws_key_pair_name" {}

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
