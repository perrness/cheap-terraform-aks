locals {
  values = <<EOT
    cniEnabled: true
    namespace: ${var.namespace}
    installNamespace: false
    controllerLogFormat: json
    enableEndpointSlices: true
    proxy:
      logFormat: json
    EOT
}

resource "helm_release" "linkerd" {
  name       = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd2"
  version    = "2.11.4"

  namespace        = var.namespace
  cleanup_on_fail  = true
  create_namespace = false

  values = compact([
    local.values
  ])

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.linkerd_trust_anchor.cert_pem
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.linkerd_issuer.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.linkerd_issuer.private_key_pem
  }

  set {
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }

  set {
    name  = "proxyInjector.externalSecret"
    value = "true"
  }

  set {
    name  = "proxyInjector.caBundle"
    value = tls_self_signed_cert.linkerd_webhook.cert_pem
  }

  set {
    name  = "policyValidator.externalSecret"
    value = "true"
  }

  set {
    name  = "policyValidator.caBundle"
    value = tls_self_signed_cert.linkerd_webhook.cert_pem
  }

  set {
    name  = "profileValidator.caBundle"
    value = tls_self_signed_cert.linkerd_webhook.cert_pem
  }

  set {
    name  = "profileValidator.externalSecret"
    value = "true"
  }

  depends_on = [
    kubernetes_manifest.linkerd_trust_anchor_certificate,
    tls_locally_signed_cert.linkerd_issuer,
    kubernetes_manifest.linkerd_webhook,
    tls_self_signed_cert.linkerd_webhook
  ]
}
