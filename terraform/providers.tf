terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-calicot-commun-001"
    storage_account_name = "stcalicotprod000"
    container_name       = "images"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

