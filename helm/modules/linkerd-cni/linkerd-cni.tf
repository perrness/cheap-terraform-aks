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

resource "helm_release" "linkerd_cni" {
  name       = "linkerd2-cni"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd2-cni"
  version    = "2.11.4"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  # values = compact([
  #   local.values
  # ])
}
