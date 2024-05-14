variable "resource_group_name" {
  type        = string
  description = "name of resource group"
  validation {
    condition     = length(var.resource_group_name) != 0
    error_message = "Resource group name cannot be empty or null"
  }
}

variable "location" {
  type        = string
  description = "resource location"
  nullable    = false
  validation {
    condition     = contains(["easteurope", "westeurope"], lower(var.location))
    error_message = "Location can be either easteurope or westeurope"
  }
}

variable "acr" {
  type        = string
  description = "azure container resource name"
  default     = "acr"
}

variable "laws_name" {
  type        = string
  description = "name of log analytics workspace"
}

variable "managed_identity_name" {
  type        = string
  description = "name of managed idenity"

}

variable "storage_account_name" {
  type        = string
  description = "name of storage account"
}

variable "tags" {
  type        = map(string)
  description = "tags to get budget of resource"
}

variable "container_app_environment_name" {
  type        = string
  description = "name of app environment"
}

variable "container_app_name" {
  type        = string
  description = "app name"

}

variable "registry_name" {
  type        = string
  description = "acr registry name"
  default     = "docker.io"
}

variable "image_name" {
  type        = string
  description = "image name"
  default     = "webapp"
}

variable "websites_port" {
  type        = string
  description = "websites port"
  default     = "3000"
}
