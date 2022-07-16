resource "azurerm_resource_group" "main" {
  name     = "${var.aks_name}-rg"
  location = "northeurope"
}

resource "azurerm_resource_group" "node_rg" {
  name     = "${var.aks_name}-node-rg"
  location = "northeurope"
}

# data "azurerm_virtual_network" "vnet" {
#   name                = var.vnet_name
#   resource_group_name = "${var.vnet_name}-rg"
# }

data "azurerm_subnet" "subnet1" {
  name                 = "${var.vnet_name}-subnet-1"
  virtual_network_name = var.vnet_name
  resource_group_name  = "${var.vnet_name}-rg"
}

data "azurerm_subnet" "subnet2" {
  name                 = "${var.vnet_name}-subnet-2"
  virtual_network_name = var.vnet_name
  resource_group_name  = "${var.vnet_name}-rg"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.aks_name}-dns"

  kubernetes_version = "1.23.5"

  node_resource_group = azurerm_resource_group.node_rg.name

  open_service_mesh_enabled = false

  private_cluster_enabled = false
  # private_dns_zone_id     = "System"

  public_network_access_enabled     = true
  role_based_access_control_enabled = true

  sku_tier = "Free"

  auto_scaler_profile {
    max_graceful_termination_sec = 300
    balance_similar_node_groups  = false
    expander                     = "least-waste"
    scale_down_delay_after_add   = "5m"
  }

  default_node_pool {
    name    = "system"
    vm_size = "standard_B2s"

    enable_auto_scaling = false
    node_count          = "1"
    max_pods            = 125

    os_disk_size_gb = "32"
    os_disk_type    = "Managed"

    pod_subnet_id  = data.azurerm_subnet.subnet1.id
    vnet_subnet_id = data.azurerm_subnet.subnet2.id

    type              = "VirtualMachineScaleSets"
    ultra_ssd_enabled = false
  }

  network_profile {
    network_plugin     = "azure"
    network_mode       = "transparent"
    network_policy     = "azure"
    load_balancer_sku  = "basic"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.3.0/24"
    dns_service_ip     = "10.0.3.12"
    ip_versions        = ["IPv4"]
  }

  identity {
    type = "SystemAssigned"
  }
}
