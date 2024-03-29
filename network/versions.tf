terraform {
  backend "azurerm" {
    key = "cheap-terraform-aks-network.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.14.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
}
