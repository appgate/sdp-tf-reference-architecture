

# this is just for demo purpose. to store API credentials to me used for autoscaling in the gateways userdata.



# resource "aws_secretsmanager_secret" "appgate_api_credentials" {
#   name        = "appgate-api-credentials"
#   description = "Appgate API credentials. Used by autoscaled gateways."
#   tags        = var.common_tags
# }

# resource "aws_secretsmanager_secret_version" "appgate_api_password" {
#   secret_id = aws_secretsmanager_secret.appgate_api_credentials.id
#   # This is just an example. dont commit the password to source control.
#   # secret_string = "admin"
#   secret_string = appgate_local_user.gateway_api_user.password
# }

