locals {
  values = <<EOT
    installCRDs: true
    serviceAccount:
      create: true
    prometheus:
      enabled: true
      servicemonitor:
        enabled: true
    EOT
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.8.2"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  values = compact([
    local.values
  ])
}
