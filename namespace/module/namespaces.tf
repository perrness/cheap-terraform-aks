resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      "linkerd.io/inject" = length(regexall("linkerd", var.name)) == 0 ? "enabled" : "disabled"
    }

    labels = {
      "prometheus" = "enabled"
    }

    name = var.name
  }
}
