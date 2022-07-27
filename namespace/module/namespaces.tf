resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      "linkerd.io/inject" = length(regexall("linkerd", var.name)) == 0 ? "enabled" : "disabled"
    }

    labels = {
      release = "kube-prometheus-stack"
    }

    name = var.name
  }
}
