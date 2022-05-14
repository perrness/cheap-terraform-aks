resource "azurerm_resource_group" "rg" {
  name     = "aks-rg"
  location = "northeurope"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "personal-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "personal-aks"

  default_node_pool {
    name       = "default"
    node_count = "1"
    vm_size    = "standard_d1_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }
}
