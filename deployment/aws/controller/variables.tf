
variable "aws_region" {}
variable "appgate_ami" {}
variable "subnet_id" {}
variable "security_group" {}
variable "controller_instance_type" {}
variable "private_key" {}
variable "public_key" {}
variable "aws_key_pair_name" {}
variable "common_tags" {}


# Network related variables
variable "vpc_id" {}
variable "appliance_cidr_block" {}
variable "ingress_cidr_blocks" {}
variable "internet_gateway_id" {}
