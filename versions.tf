terraform {
  backend "azurerm" {
    resource_group_name  = "tamopstfstates"
    storage_account_name = "pertamopstf"
    container_name       = "tfstatedevops"
    key                  = "tfstatekubernetes.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}