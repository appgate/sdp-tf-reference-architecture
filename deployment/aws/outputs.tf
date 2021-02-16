
output "gateway_dns" {
  value = aws_instance.appgate_gateway.public_dns
}
