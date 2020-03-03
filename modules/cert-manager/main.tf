data "helm_repository" "jetstack" {
  name = "jetstack"
  url = "https://charts.jetstack.io"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

locals {
  values = {
    nodeSelector = var.node_selector
    webhook = {
      nodeSelector = var.node_selector
    }
    cainjector = {
      nodeSelector = var.node_selector
    }
  }
}

module "crds" {
  source = "./modules/crds"
}

resource "helm_release" "cert-manager" {
  name = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart = "cert-manager"
  namespace = kubernetes_namespace.cert-manager.metadata[0].name

  values = [yamlencode(local.values)]

  depends_on = [module.crds.req]
}

module "issuers" {
  source = "./modules/issuers"

  production_email = var.issuers_email
  staging_email = var.issuers_email

  dep = [module.crds.req, helm_release.cert-manager]
}
