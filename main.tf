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
  name                = vars.laws_name
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
  scope              = azuerm_storage_account.webapp.id
  role_definition_id = "Storage Table Data Contributor"
  principal_id       = azurerm_user_assigned_identity.managed_identity.principal_id
  depends_on         = [azurerm_storage_account.webapp]
}

resource "azurerm_storage_account" "webapp" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.webapp.name
  location                 = azurerm_resource_group.webapp.location
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

resource "azurerem_container_app_environment" "webapp" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.webapp.location
  resource_group_name        = azurerm_resource_group.webapp.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.webapp.id
}

resource "azurerem_container_app" "webapp" {
  name                         = var.container_app_name
  container_app_environment_id = azurerem_container_app_environment.webapp.id
  resource_group_name          = azurerem_container_app_environment.webapp.id
  revision_mode                = "Single"
  tags                         = var.tags
  registry {
    server  = data.azurerm_container_registry.acr.login_server
    idenity = resource.azurerm_user_assigned_identity.managed_identity.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [resource.azurerm_user_assigned_identity.managed_identity.id]
  }

  secret {
    name  = "azure-tables-url"
    value = "https://${var.storage_account_name}.table.core.windows.net/"
  }
  secret {
    name  = "azure-tables-client-id"
    value = azurerm_user_assigned_identity.managed_identity.client_id
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
        name        = "AZURE_TABLES_SERVICE_URL"
        secret_name = "azure-tables-service-url"
      }
      env {
        name        = "AZURE_TABLES_CLIENT_ID"
        secret_name = "azure-tables-client-id"
      }
    }
  }
}

output "app_url" {
  value = "https://${azurerem_container_app.webapp.name}.azurewebsites.net"
}