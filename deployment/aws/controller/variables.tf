
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
variable "vpc_id" {
  description = "VPC used for appgate."
  default     = "vpc-1e9b5879"
}
variable "appliance_cidr_block" {
  description = "The network addresses used for appliances."
  default     = "10.0.242.0/24"
  # default     = "172.31.252.0/24" # stockholm
}
variable "internet_gateway_id" {
  default = "igw-e2dfaa86"
}
