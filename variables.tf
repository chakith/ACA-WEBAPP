variable "resource_group_name" {
  type        = string
  description = "name of resource group"
}

variable "location" {
  type        = string
  description = "resource location"
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
