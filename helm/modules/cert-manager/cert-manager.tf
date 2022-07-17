locals {
  values = <<EOT
    installCRDs: true
    serviceAccount:
      create: true
    prometheus:
      enabled: true
      servicemonitor:
        enabled: false
        prometheusInstance: default
        targetPort: 9402
        path: /metrics
        interval: 60s
        scrapeTimeout: 30s
        labels: {}
        honorLabels: false
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
