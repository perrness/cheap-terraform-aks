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
      prometheusSpec:
        podMonitorSelector: {}
        podMonitorSelectorNilUsesHelmValues: false
        ruleSelector: {}
        ruleSelectorNilUsesHelmValues: false
        serviceMonitorSelector: {}
        serviceMonitorSelectorNilUsesHelmValues: false
        additionalScrapeConfigs:
        - job_name: 'linkerd-controller'
          kubernetes_sd_configs:
          - role: pod
            namespaces:
              names:
              - linkerd
              - linkerd-viz
          relabel_configs:
          - source_labels:
            - __meta_kubernetes_pod_container_port_name
            action: keep
            regex: admin-http
          - source_labels: [__meta_kubernetes_pod_container_name]
            action: replace
            target_label: component

        - job_name: 'linkerd-service-mirror'
          kubernetes_sd_configs:
          - role: pod
          relabel_configs:
          - source_labels:
            - __meta_kubernetes_pod_label_linkerd_io_control_plane_component
            - __meta_kubernetes_pod_container_port_name
            action: keep
            regex: linkerd-service-mirror;admin-http$
          - source_labels: [__meta_kubernetes_pod_container_name]
            action: replace
            target_label: component

        - job_name: 'linkerd-proxy'
          kubernetes_sd_configs:
          - role: pod
          relabel_configs:
          - source_labels:
            - __meta_kubernetes_pod_container_name
            - __meta_kubernetes_pod_container_port_name
            - __meta_kubernetes_pod_label_linkerd_io_control_plane_ns
            action: keep
            regex: ^{{default .Values.proxyContainerName "linkerd-proxy" .Values.proxyContainerName}};linkerd-admin;{{.Values.linkerdNamespace}}$
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: pod
          # special case k8s' "job" label, to not interfere with prometheus' "job"
          # label
          # __meta_kubernetes_pod_label_linkerd_io_proxy_job=foo =>
          # k8s_job=foo
          - source_labels: [__meta_kubernetes_pod_label_linkerd_io_proxy_job]
            action: replace
            target_label: k8s_job
          # drop __meta_kubernetes_pod_label_linkerd_io_proxy_job
          - action: labeldrop
            regex: __meta_kubernetes_pod_label_linkerd_io_proxy_job
          # __meta_kubernetes_pod_label_linkerd_io_proxy_deployment=foo =>
          # deployment=foo
          - action: labelmap
            regex: __meta_kubernetes_pod_label_linkerd_io_proxy_(.+)
          # drop all labels that we just made copies of in the previous labelmap
          - action: labeldrop
            regex: __meta_kubernetes_pod_label_linkerd_io_proxy_(.+)
          # __meta_kubernetes_pod_label_linkerd_io_foo=bar =>
          # foo=bar
          - action: labelmap
            regex: __meta_kubernetes_pod_label_linkerd_io_(.+)
          # Copy all pod labels to tmp labels
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
            replacement: __tmp_pod_label_$1
          # Take `linkerd_io_` prefixed labels and copy them without the prefix
          - action: labelmap
            regex: __tmp_pod_label_linkerd_io_(.+)
            replacement:  __tmp_pod_label_$1
          # Drop the `linkerd_io_` originals
          - action: labeldrop
            regex: __tmp_pod_label_linkerd_io_(.+)
          # Copy tmp labels into real labels
          - action: labelmap
            regex: __tmp_pod_label_(.+)
    prometheusOperator:
      enabled: true
      admissionWebhooks:
        certManager: 
          enabled: true
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
