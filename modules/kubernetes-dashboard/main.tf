data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

locals {
  values = {
    extraArgs = ["--token-ttl", "0"]
    nodeSelector = var.node_selector
    ingress = {
      enabled = true
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "kubernetes.io/tls-acme" = "true"
        "cert-manager.io/cluster-issuer" = var.ingress.issuer
        "ingress.kubernetes.io/ssl-redirect" = "true"
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }
      hosts = [var.ingress.domain]
      tls = [
        {
          secretName = var.ingress.name
          hosts = [var.ingress.domain]
        }
      ]
    }
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name = "kubernetes-dashboard"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "kubernetes-dashboard"
  namespace = "kube-system"

  values = [yamlencode(local.values)]
}
