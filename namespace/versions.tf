terraform {
  backend "azurerm" {
    key = "cheap-terraform-aks-namespaces.tfstate"
  }

  required_providers {
    required_providers {
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "2.12.1"
      }
    }
  }
}

provider "kubernetes" {}
