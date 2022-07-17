# locals {
#   values = <<EOT
#     namespaceOverride: monitoring
#     grafana:
#       namespaceOverride: monitoring
#       adminPassword: admin
#     kube-state-metrics:
#       namespaceOverride: monitoring
#     prometheus-node-exporter:
#       namespaceOverride: monitoring
#     prometheus:
#       enabled: true
#     prometheusSpec:
#       serviceMonitorSelector:
#       matchLabels:
#         release: linkerd-cni
#       serviceMonitorNamespaceSelector: {}
#     EOT
# }

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.8.2"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  # values = compact([
  #   local.values
  # ])
}
