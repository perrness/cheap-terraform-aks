resource "tls_private_key" "linkerd_trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "linkerd_issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "linkerd_issuer" {
  private_key_pem = tls_private_key.linkerd_issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_self_signed_cert" "linkerd_trust_anchor" {
  private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  validity_period_hours = 168
  early_renewal_hours   = 154
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "client_auth",
    "server_auth",
  ]
}

resource "tls_locally_signed_cert" "linkerd_issuer" {
  cert_request_pem   = tls_cert_request.linkerd_issuer.cert_request_pem
  ca_private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.linkerd_trust_anchor.cert_pem

  validity_period_hours = 168
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "client_auth",
    "server_auth",
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
}

resource "kubernetes_manifest" "linkerd_trust_anchor" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "linkerd-trust-anchor"
      namespace = var.namespace
    }
    spec = {
      ca = {
        secretName = "linkerd-trust-anchor"
      }
    }
  }
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
}
