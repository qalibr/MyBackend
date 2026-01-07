variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID."
  sensitive   = false
}

variable "client_id" {
  type        = string
  description = "The Client ID for the Service Principal."
  sensitive   = false
}

variable "client_secret" {
  type        = string
  description = "The Client Secret for the Service Principal."
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "The Tenant ID for the Azure Directory."
  sensitive   = false
}

variable "location" {
  type        = string
  description = "The Azure region where all resources will be deployed."
  default     = "norwayeast"
}

variable "acr_name" {
  type        = string
  description = "The unique name of the Azure Container Registry."
}