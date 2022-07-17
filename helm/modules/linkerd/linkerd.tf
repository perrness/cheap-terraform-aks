locals {
  values = <<EOT
    cniEnabled: true
    EOT
}

resource "tls_private_key" "linkerd_trust_anchor" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "linkerd_trust_anchor" {
  private_key_pem = tls_private_key.linkerd_trust_anchor.public_key_pem

  subject {
    common_name  = "cheap.com"
    organization = "Cheap AKS"
  }

  validity_period_hours = 12
  is_ca_certificate     = true

  allowed_uses = [
    "client_auth",
    "server_auth",
  ]

  depends_on = [
    tls_private_key.linkerd_trust_anchor
  ]
}

resource "kubernetes_secret" "linkerd_trust_anchor" {
  metadata {
    name = "linkerd-trust-anchor"
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
      namespace = "linkerd"
    }
    spec = {
      secretName  = "linkerd-identity-issuer"
      duration    = "48h"
      renewBefore = "25h"
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
  name       = "linkerd2"
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
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }

  depends_on = [
    kubernetes_manifest.linkerd_trust_anchor_certificate
  ]
}
