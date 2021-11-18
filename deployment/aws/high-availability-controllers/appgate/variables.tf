variable "appgate_config_file" {
  type = string
}

variable "private_key" {
  type = string
}


variable "aws_region" {
  description = "AWS region to launch servers."
}
variable "appgate_ami" {
  type = string
}
variable "controller_instance_type" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "security_group" {
  type = string
}
variable "aws_key_pair_name" {
  type = string
}
variable "common_tags" {
  type    = map(any)
  default = {}
}
