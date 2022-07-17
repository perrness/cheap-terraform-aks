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
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
}
