data "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  resource_group_name = "${var.aks_name}-rg"
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
    username               = data.azurerm_kubernetes_cluster.main.kube_config.0.username
    password               = data.azurerm_kubernetes_cluster.main.kube_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

module "kube-prometheus-stack" {
  source = "./modules/kube-prometheus-stack"

  namespace = "monitoring"
}

module "cert-manager" {
  source = "./modules/cert-manager"

  namespace = "cert-manager"
}

module "linkerd-cni" {
  source = "./modules/linkerd-cni"

  namespace = "linkerd-cni"
}

module "linkerd" {
  source = "./modules/linkerd"

  namespace = "linkerd"
}
