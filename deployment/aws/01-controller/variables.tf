
variable "aws_region" {}
variable "appgate_ami" {}
variable "subnet_id" {}
variable "security_group" {}
variable "controller_instance_type" {}
variable "private_key" {
  description = "Path to SSH private key that is used with key_name."
}
variable "aws_key_pair_name" {}
variable "common_tags" {}
