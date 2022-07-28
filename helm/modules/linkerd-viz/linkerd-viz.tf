locals {
  values = <<EOT
    installNamespace: true
    defaultLogFormat: json
    namespace: linkerd-viz
    linkerdNamespace: linkerd
    EOT
}

resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-viz"
  version    = "2.11.4"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  values = compact([
    local.values
  ])
}
