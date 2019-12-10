locals {
  crds = {
    alertmanager = "https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/crds/crd-alertmanager.yaml"
    prometheus = "https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/crds/crd-prometheus.yaml"
    prometheusrules = "https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/crds/crd-prometheusrules.yaml"
    servicemonitor = "https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/crds/crd-servicemonitor.yaml"
    podmonitor = "https://raw.githubusercontent.com/helm/charts/master/stable/prometheus-operator/crds/crd-podmonitor.yaml"
  }
}

data "http" "crd_manifests" {
  for_each = local.crds
  url = each.value
}

resource "kubectl_manifest" "crds" {
  for_each = data.http.crd_manifests
  yaml_body = each.value["body"]
}

data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "random_string" "prometheus-password" {
  length = 16
  special = false
}

locals {
  username = "admin"
  password = random_string.prometheus-password.result
}

module "basic-auth" {
  source = "./../../common/basic-auth"

  password = local.password
  username = local.username
}

resource "kubernetes_secret" "prometheus-basic-auth" {
  metadata {
    name = "prometheus-basic-auth"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
  }
  data = {
    auth = module.basic-auth.auth
  }
  type = "Opaque"
}

resource "random_string" "grafana-password" {
  length = 16
  special = false
}

locals {
  # workaround for https://github.com/hashicorp/terraform/issues/22405
  ingress_json = {
    for name, config in var.configs:
      name => lookup(config, "ingress", false) != false ? jsonencode({
        enabled = true
        hosts = [config["ingress"]["domain"]]
        tls = [
          {
            secretName = config["ingress"]["domain"]
            hosts = [config["ingress"]["domain"]]
          }
        ]
        annotations = merge({
          "kubernetes.io/ingress.class" = "nginx"
          "kubernetes.io/tls-acme" = "true"
          "cert-manager.io/cluster-issuer" = config["ingress"]["issuer"]
        }, jsondecode(lookup(config, "http_auth", true) != false ? jsonencode({
          "nginx.ingress.kubernetes.io/auth-type" = "basic"
          "nginx.ingress.kubernetes.io/auth-secret" = kubernetes_secret.prometheus-basic-auth.metadata[0].name
          "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required"
        }) : jsonencode({})))
      }) : jsonencode({})
  }
  ingress = {
    for name, json in local.ingress_json:
      name => jsondecode(json)
  }
  # end of workaround
  disabled_component = {
    enabled = false
  }
  values = {
    alertmanager = {
      ingress = local.ingress["alertmanager"]
      alertmanagerSpec = {
        nodeSelector = var.configs["alertmanager"].node_selector
        storage = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = var.configs["alertmanager"].storage_class
              accessModes = [var.configs["prometheus"].storage_mode]
              resources = {
                requests = {
                  storage = var.configs["alertmanager"].storage_size
                }
              }
            }
          }
        }
      }
    }
    grafana = {
      ingress = local.ingress["grafana"]
      adminPassword = random_string.grafana-password.result
    }
    kubeScheduler = local.disabled_component
    kubeControllerManager = local.disabled_component
    kubeEtcd = local.disabled_component
    prometheusOperator = {
      createCustomResource = false
      nodeSelector = var.configs["operator"].node_selector
    }
    prometheus = {
      ingress = local.ingress["prometheus"]
      prometheusSpec = {
        nodeSelector = var.configs["prometheus"].node_selector
        storageSpec = {
          volumeClaimTemplate = {
            spec = {
              storageClassName = var.configs["prometheus"].storage_class
              accessModes = [var.configs["prometheus"].storage_mode]
              resources = {
                requests = {
                  storage = var.configs["prometheus"].storage_size
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "helm_release" "prometheus-operator" {
  name = "prometheus-operator"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "prometheus-operator"
  namespace = kubernetes_namespace.prometheus.metadata[0].name

  values = [yamlencode(local.values)]

  depends_on = [kubectl_manifest.crds]
}
