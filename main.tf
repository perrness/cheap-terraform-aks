resource "azurerm_resource_group" "main" {
  name     = "per-aks-rg"
  location = "northeurope"
}

data "azurerm_subnet" "subnet1" {
  name                 = "per-subnet-1"
  virtual_network_name = "per-virtual-network"
  resource_group_name  = "per-virtual-network-rg"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "per-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "per-aks"

  kubernetes_version = "1.25"

  open_service_mesh_enabled = false
  private_cluster_enabled   = false

  private_dns_zone_id = "System"

  public_network_access_enabled = false

  sku_tier = "Free"

  auto_scaler_profile {
    balance_similar_node_groups = false
    expander                    = "least-waste"
    scale_down_delay_after_add  = "5m"
  }

  default_node_pool {
    name    = "default"
    vm_size = "standard_B2s"

    enable_auto_scaling = false
    node_count          = "1"
    max_pods            = 125

    os_disk_size = "32gb"
    os_disk_type = "Ephemeral"

    pod_subnet_id = data.azurerm_subnet.subnet1.id

    type              = "VirtualMachineScaleSets"
    ultra_ssd_enabled = false
  }

  network_profile {
    network_plugin    = "azure"
    network_mode      = "transparent"
    network_policy    = "calico"
    load_balancer_sku = "basic"
  }

  identity {
    type = "SystemAssigned"
  }
}
