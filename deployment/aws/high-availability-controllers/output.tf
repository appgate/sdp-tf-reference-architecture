output "controller_ui" {
  value = format("https://%s:8443", module.aws_resources.controller_dns)
}
