resource "azurerm_resource_group" "main" {
  name     = "${var.vnet_name}-rg"
  location = var.location
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
  address_space       = ["10.52.0.0/16"]

  subnet {
    name           = "${var.vnet_name}-subnet-1"
    address_prefix = "10.52.0.0/24"
    security_group = azurerm_network_security_group.main.id
  }
}
