terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {} # Stockage distant (configurer selon besoin)
}

provider "azurerm" {
  features {}
}

