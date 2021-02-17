output "controller_dns" {
  value = aws_instance.appgate_controller.public_dns
}
