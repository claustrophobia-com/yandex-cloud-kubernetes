locals {
  kibana = {
    apiVersion = "kibana.k8s.elastic.co/v1beta1"
    kind = "Kibana"
    metadata = {
      name = var.cluster_name
      namespace = var.namespace
    }
    spec = {
      version = "7.5.0"
      count = 1
      elasticsearchRef = {
        name = var.cluster_name
      }
      podTemplate = {
        spec = {
          nodeSelector = var.node_selector
        }
      }
      http = {
        tls = {
          selfSignedCertificate = {
            disabled = true
          }
        }
      }
    }
  }
}
resource "kubectl_manifest" "kibana" {
  yaml_body = yamlencode(local.kibana)
}

resource "kubernetes_ingress" "kibana" {
  metadata {
    name = "${var.cluster_name}-kb"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "cert-manager.io/cluster-issuer" = var.ingress.issuer
      "ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }
  spec {
    rule {
      host = var.ingress.domain
      http {
        path {
          backend {
            service_name = "${var.cluster_name}-kb-http"
            service_port = 5601
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = [var.ingress.domain]
      secret_name = "${var.cluster_name}-kb"
    }
  }
}
