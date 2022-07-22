resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }

    labels = {
      release = "kube-prometheus-stack"
    }

    name = var.name
  }
}
