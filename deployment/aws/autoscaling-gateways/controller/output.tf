output "controller_dns" {
  value = aws_instance.appgate_controller.public_dns
}


output "key_name" {
  value = aws_key_pair.deployer[0].id
}


output "controller_security_groups" {
  value = [var.security_group == "" ? aws_security_group.appgate_security_group[0].id : var.security_group]
}
output "controller_subnet" {
  value = aws_instance.appgate_controller.subnet_id
}
