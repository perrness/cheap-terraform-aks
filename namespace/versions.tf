terraform {
  backend "azurerm" {
    key = "cheap-terraform-aks-namespaces.tfstate"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "=3.14.0"
    # }
  }
}

# provider "azurerm" {
#   use_oidc = true
#   features {}
# }
