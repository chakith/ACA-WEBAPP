terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
     # version = ">3.0.0"
    }
  }
}



provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "webapp" {
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_container_registry" "acr" {
  resource_group_name = var.resource_group_name
  name                = var.acr
}

resource "azurerm_log_analytics_workspace" "webapp-laws" {
  name                = var.laws_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = var.managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "assign_identity_storage_blob_data_contributor" {
  scope              = azurerm_storage_account.webapp.id
  role_definition_id = "Storage Table Data Contributor"
  principal_id       = azurerm_user_assigned_identity.managed_identity.principal_id
  depends_on         = [azurerm_storage_account.webapp]
}

resource "azurerm_storage_account" "webapp" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.webapp.name
  location                 = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  identity {
    type         = "UserAssigned"
    identity_ids = [resource.azurerm_user_assigned_identity.managed_identity.id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "role_assignment_pull" {
  scope              = data.azurerm_container_registry.acr.id
  role_definition_id = "AcrPull"
  principal_id       = resource.azurerm_user_assigned_identity.managed_identity.principal_id
}

resource "azurerm_container_app_environment" "webapp" {
  name                       = var.container_app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = resource.azurerm_log_analytics_workspace.webapp-laws.id
  depends_on = [ azurerm_log_analytics_workspace.webapp-laws ]
}

resource "azurerm_container_app" "webapp" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.webapp.id
  resource_group_name          = azurerm_resource_group.webapp.name
  revision_mode                = "Single"
  tags                         = var.tags
  registry {
    server  = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.managed_identity.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [resource.azurerm_user_assigned_identity.managed_identity.id]
  }

  secret {
    name  = "client-id"
    value = resource.azurerm_user_assigned_identity.managed_identity.client_id
  }
  template {
    container {
      name   = var.container_app_name
      image  = var.image_name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "WEBSITES_PORT"
        value = var.websites_port
      }
      env {
        name        = "CLIENT_ID"
        secret_name = "client-id"
      }
      # TODO 
    }
  }
}

output "app_url" {
  value = "https://${azurerm_container_app.webapp.name}.azurewebsites.net"
}