output "controller_dns" {
  value = aws_instance.appgate_controller.public_dns
}


output "key_name" {
  value = aws_key_pair.deployer[0].id
}
