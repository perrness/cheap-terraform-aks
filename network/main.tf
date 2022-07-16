resource "azurerm_resource_group" "main" {
  name     = "${var.vnet_name}-rg"
  location = "northeurope"
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.vnet_name}-security-group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "${var.vnet_name}-subnet-1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "${var.vnet_name}-subnet-2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.main.id
  }
}
