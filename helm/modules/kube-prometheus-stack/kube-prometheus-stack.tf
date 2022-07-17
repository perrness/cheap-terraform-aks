locals {
  values = <<EOT
    namespaceOverride: monitoring
    grafana:
      namespaceOverride: monitoring
      adminPassword: admin
    kube-state-metrics:
      namespaceOverride: monitoring
    prometheus-node-exporter:
      namespaceOverride: monitoring
    prometheus:
      enabled: true
    prometheusOperator:
      admissionWebhooks:
        certManager: true
    prometheusSpec:
      serviceMonitorSelector:
      matchLabels:
        release: kube-prometheus-stack
      serviceMonitorNamespaceSelector: {}
    EOT
}

resource "helm_release" "kube_promethus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "37.2.0"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  values = compact([
    local.values
  ])
}
