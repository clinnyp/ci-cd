terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Random suffix for global uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "hono-app-rg"
  location = "New Zealand North"
}

# Container registry
resource "azurerm_container_registry" "acr" {
  name                = "honoapp${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# App Service Plan 
resource "azurerm_service_plan" "plan" {
  name                = "hono-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Web App for Containers
resource "azurerm_linux_web_app" "webapp" {
  name                = "hono-app-web-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/hono-app:latest"
  }

  app_settings = {
    "WEBSITES_PORT" = "3000" # important: expose container port
  }

  https_only = true
}

# Varialbes

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
  default     = "latest"
}

# Outputs
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "Login server for ACR"
  sensitive   = true
}

output "acr_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "Admin username for ACR"
  sensitive   = true
}

output "acr_password" {
  value       = azurerm_container_registry.acr.admin_password
  description = "Admin password for ACR"
  sensitive   = true
}

output "webapp_url" {
  value       = azurerm_linux_web_app.webapp.default_hostname
  description = "URL of the deployed Web App"
}

output "webapp_name" {
  value       = azurerm_linux_web_app.webapp.name
  description = "Name of the deployed Web App"
}

output "rg_name" {
  value       = azurerm_resource_group.rg.name
  description = "Name of the resource group"
}