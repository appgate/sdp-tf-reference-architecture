output "controller_ui" {
  value = format("https://%s:8443", module.controller.controller_dns)
}
