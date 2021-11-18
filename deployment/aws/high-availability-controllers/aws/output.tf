
output "key_name" {
  value = aws_key_pair.deployer[0].id
}


output "controller_security_groups" {
  value = [var.security_group == "" ? aws_security_group.appgate_security_group[0].id : var.security_group]
}
output "controller_subnet" {
  value = aws_instance.first_controller.subnet_id
}

output "controller_dns" {
  value = aws_instance.first_controller.public_dns
}

output "first_controller_subnet_id" {
  value = aws_subnet.appgate_appliance_subnet[0].id
}
output "first_controller_security_group" {
  value = aws_security_group.appgate_security_group[0].id
}
output "first_controller_key_pair" {
  value = aws_key_pair.deployer[0].key_name
}
