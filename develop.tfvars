resource_group_name   = "webapp-dev"
location              = "westeurope"
registry_name         = "acr"
managed_identity_name = "webapp-mi-dev"
storage_account_name  = "webappsadev"
laws_name             = "webapp-laws-dev"
tags = {
  environment = "dev"
  name        = "webapp-dev"
}
container_app_environment_name = "dev"
container_app_name             = "webapp"