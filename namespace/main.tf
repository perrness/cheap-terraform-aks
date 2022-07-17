data "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  resource_group_name = "${var.aks_name}-rg"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

module "namespace" {
  source = "./module"

  for_each = var.namespaces

  name = each.key
}
