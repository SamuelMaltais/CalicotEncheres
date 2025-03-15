resource "azurerm_resource_group" "rg" {
  name     = "rg-calicot-dev-${var.code_identification}"
  location = "Canada Central"
}

# Network vpn

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev-calicot-cc-${var.code_identification}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet_web" {
  name                 = "snet-dev-web-cc-${var.code_identification}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet_db" {
  name                 = "snet-dev-db-cc-${var.code_identification}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Web app

resource "azurerm_service_plan" "plan" {
  name                = "plan-calicot-dev-${var.code_identification}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_app_service" "app" {
  name                = "app-calicot-dev-${var.code_identification}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.plan.id

  site_config {
    always_on          = true
    min_tls_version    = "1.2"
  }

  https_only         = true

  app_settings = {
    "ImageUrl" = "https://stcalicotprod000.blob.core.windows.net/images/"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Autoscaling of web app
resource "azurerm_monitor_autoscale_setting" "auto_scale" {
  name                = "autoscale-app-calicot-dev-${var.code_identification}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  target_resource_id  = azurerm_service_plan.plan.id

  profile {
    name = "default"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        operator           = "GreaterThan"
        threshold          = 70
        time_aggregation   = "Average"
        time_window        = "PT5M"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }
}

