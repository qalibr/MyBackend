terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Authenticate using the variables from terraform.tfvars
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-student-backend-norway"
  location = var.location # Data Residency!
}

# 2. Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic" # budget friendly
  admin_enabled       = true    # For simple auth
}

# 3. Log Analytics
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "logs-student-backend"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 4. Container Apps Environment
resource "azurerm_container_app_environment" "env" {
  name                       = "env-student-backend"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}

# 5. The App
resource "azurerm_container_app" "app" {
  name                         = "app-fastapi-backend"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single" # Simplifying versioning

  # Ignore changes to the image tag so CI/CD deployments 
  # don't get reverted by Terraform runs
  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  template {
    container {
      name   = "fastapi-container"
      image  = "${azurerm_container_registry.acr.login_server}/fastapi-backend:initial" # Placeholder image
      cpu    = 0.25
      memory = "0.5Gi"
      
      env {
        name  = "ENV_NAME"
        value = "Production"
      }

      # Liveness probe to check if the app is running.
      # If this fails, Azure will restart the container.
      liveness_probe {
        transport = "HTTP"
        path      = "/health"
        port      = 8000
        initial_delay = 20 # Give the app time to start
        interval_seconds = 30
      }

      # Readiness probe to check if the app is ready for traffic.
      # If this fails, Azure will not send traffic to this replica.
      readiness_probe {
        transport = "HTTP"
        path      = "/health"
        port      = 8000
        interval_seconds = 10
      }
    }

    # This stops Azure leaving us with no containers (replicas) after inactivity.
    # We were incurring ~1.5 NOK per day before this change.    
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app
    min_replicas = 1
    # max_replicas = 2 # Allow scaling up to 2 replicas under load
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8000
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}