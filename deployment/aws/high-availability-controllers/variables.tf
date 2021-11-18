
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
variable "appgate_ami" {
  type        = string
  description = "Prefer to ignore: Consider using the appgate_version + licensing_type parameters to locate your AMI. Only specify if you want to override AMI looking."
  default     = ""
}
variable "subnet_id" {
  type        = string
  default     = ""
  description = "if blank, will create a security group"
}
variable "security_group" {
  type        = string
  default     = ""
  description = "if blank, will create a security group"
}

variable "controller_instance_type" {
  default     = "m4.xlarge"
  type        = string
  description = "Size of instance to deploy. Vendor recommends c5.xlarge"
  # options:
  # t2/3. micro, medium, large
  # c4/5. xlarge, 2xlarge, 4xlarge
  # c5.large
  # m4/5. large, xlarge, 2xlarge, 4xlarge
  # r4. large,xlarge
  validation {
    condition     = can(regex("(t(2|3)\\.(small|medium|large)|c(4|5)\\.(|2|4)xlarge|c5.large|m(4|5)\\.(|x|2x|4x)large|r4\\.(|x)large)", var.controller_instance_type))
    error_message = "ERROR Must be a valid instance size, see variable description."
  }
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


locals {
  service_name = "appgate"
  owner        = "dln"

  # Common tags to be assigned to all aws resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
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
  default   = "adminadmin"
  sensitive = true
}
