terraform {
  backend "azurerm" {
    key = "cheap-terraform-aks-helm.tfstate"
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
}
