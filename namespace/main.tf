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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "monitoring"
  }
}

resource "kubernetes_namespace" "linkerd" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "linkerd"
  }
}

resource "kubernetes_namespace" "linkerd_viz" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "linkerd-viz"
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "apps"
  }
}
