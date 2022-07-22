locals {
  values = <<EOT
    cniEnabled: true
    namespace: ${var.namespace}
    installNamespace: false
    controllerLogFormat: json
    controllerLogLevel: debug
    enableEndpointSlices: true
    proxy:
      logFormat: json
    EOT
}

resource "tls_private_key" "linkerd_trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "linkerd_issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "linkerd_trust_anchor" {
  private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  validity_period_hours = 168
  early_renewal_hours   = 24 * 30 * 11
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "client_auth",
    "server_auth",
  ]

  depends_on = [
    tls_private_key.linkerd_trust_anchor
  ]
}

resource "tls_self_signed_cert" "linkerd_issuer" {
  private_key_pem = tls_private_key.linkerd_issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }

  validity_period_hours = 168
  early_renewal_hours   = 24 * 30 * 11
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "client_auth",
    "server_auth",
  ]

  depends_on = [
    tls_private_key.linkerd_issuer
  ]
}

resource "kubernetes_secret" "linkerd_trust_anchor" {
  metadata {
    name      = "linkerd-trust-anchor"
    namespace = var.namespace
  }
  data = {
    "tls.crt" = tls_self_signed_cert.linkerd_trust_anchor.cert_pem
    "tls.key" = tls_private_key.linkerd_trust_anchor.private_key_pem # key used to generate Certificate Request
  }
  type = "kubernetes.io/tls"

  depends_on = [
    tls_self_signed_cert.linkerd_trust_anchor
  ]
}

resource "kubernetes_manifest" "linkerd_trust_anchor" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "linkerd-trust-anchor"
      "namespace" = var.namespace
    }
    "spec" = {
      "ca" = {
        "secretName" = "linkerd-trust-anchor"
      }
    }
  }

  depends_on = [
    kubernetes_secret.linkerd_trust_anchor
  ]
}

resource "kubernetes_manifest" "linkerd_trust_anchor_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-identity-issuer"
      namespace = var.namespace
    }
    spec = {
      secretName  = "linkerd-identity-issuer"
      duration    = "48h0m0s"
      renewBefore = "25h0m0s"
      issuerRef = {
        name = "linkerd-trust-anchor"
        kind = "Issuer"
      }
      commonName = "identity.linkerd.cluster.local"
      dnsNames   = ["identity.linkerd.cluster.local"]
      isCA       = true
      privateKey = {
        algorithm : "ECDSA"
      }
      usages = [
        "cert sign",
        "crl sign",
        "server auth",
        "client auth",
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.linkerd_trust_anchor
  ]
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
    value = tls_self_signed_cert.linkerd_issuer.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_self_signed_cert.linkerd_issuer.private_key_pem
  }

  set {
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }

  depends_on = [
    kubernetes_manifest.linkerd_trust_anchor_certificate,
    tls_self_signed_cert.linkerd_issuer
  ]
}
