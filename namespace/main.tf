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
