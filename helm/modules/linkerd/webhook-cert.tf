resource "tls_private_key" "linkerd_webhook" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "linkerd_webhook" {
  private_key_pem = tls_private_key.linkerd_webhook.private_key_pem

  subject {
    common_name = "webhook.linkerd.cluster.local"
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

resource "kubernetes_secret" "linkerd_webhook" {
  metadata {
    name      = "webhook-issuer-tls"
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.linkerd_webhook.cert_pem
    "tls.key" = tls_private_key.linkerd_webhook.private_key_pem # key used to generate Certificate Request
  }
}

resource "kubernetes_manifest" "linkerd_webhook" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "webhook-issuer"
      namespace = var.namespace
    }
    spec = {
      ca = {
        secretName = "webhook-issuer-tls"
      }
    }
  }
}

resource "kubernetes_manifest" "linkerd_policy_validator" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-policy-validator"
      namespace = "linkerd"
    }
    spec = {
      secretName  = "linkerd-policy-validator-k8s-tls"
      duration    = "24h0m0s"
      renewBefore = "1h0m0s"
      issuerRef = {
        name = "webhook-issuer"
        kind = "Issuer"
      }
      commonName = "linkerd-policy-validator.linkerd.svc"
      dnsNames = [
        "linkerd-policy-validator.linkerd.svc"
      ]
      privateKey = {
        algorithm = "ECDSA"
        encoding  = "PKCS8"
      }
      usages = [
        "server auth"
      ]
    }
  }
}

resource "kubernetes_manifest" "linkerd_proxy_injector" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-proxy-injector"
      namespace = "linkerd"
    }
    spec = {
      secretName  = "linkerd-proxy-injector-k8s-tls"
      duration    = "24h0m0s"
      renewBefore = "1h0m0s"
      issuerRef = {
        name = "webhook-issuer"
        kind = "Issuer"
      }
      commonName = "linkerd-proxy-injector.linkerd.svc"
      dnsNames = [
        "linkerd-proxy-injector.linkerd.svc"
      ]
      privateKey = {
        algorithm = "ECDSA"
      }
      usages = [
        "server auth"
      ]
    }
  }
}

resource "kubernetes_manifest" "linkerd_sp_validator_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "linkerd-sp-validator"
      namespace = "linkerd"
    }
    spec = {
      secretName  = "linkerd-sp-validator-k8s-tls"
      duration    = "24h0m0s"
      renewBefore = "1h0m0s"
      issuerRef = {
        name = "webhook-issuer"
        kind = "Issuer"
      }
      commonName = "linkerd-sp-validator.linkerd.svc"
      dnsNames = [
        "linkerd-sp-validator.linkerd.svc"
      ]
      privateKey = {
        algorithm = "ECDSA"
      }
      usages = [
        "server auth"
      ]
    }
  }
}
