# ACA-WebApp

## Usage of Module 

```

module "aca-app" {
    source = "git::https://github.com/chakith/aca-webapp?ref=tags/v1.0.0"
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
}

```


## Usage of Module 
```

terraform init
terraform plan -var-file=develop.tfvars
terraform apply -var-file=develop.tfvars -auto-approve
terraform destroy -var-file=develop.tfvars

```

