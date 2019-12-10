data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

locals {
  values = {
    controller = {
      kind = "DaemonSet"
      nodeSelector = var.node_selector
    }
    defaultBackend = {
      nodeSelector = var.node_selector
    }
  }
}

resource "helm_release" "nginx-ingress" {
  name = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "nginx-ingress"
  version = "1.26.1"
  namespace = kubernetes_namespace.nginx-ingress.metadata[0].name

  values = [yamlencode(local.values)]
}

data "kubernetes_service" "nginx-ingress" {
  depends_on = [helm_release.nginx-ingress]
  metadata {
    name = "${helm_release.nginx-ingress.name}-controller"
    namespace = kubernetes_namespace.nginx-ingress.metadata[0].name
  }
}
