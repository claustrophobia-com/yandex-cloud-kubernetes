data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

locals {
  values = {
    persistence = {
      enabled = true
      storageClass = var.storage_class
      size = var.storage_size
    }
    storageClass = {
      name = "nfs-client"
      reclaimPolicy = "Retain"
    }
    nodeSelector = var.node_selector
  }
}

resource "kubernetes_namespace" "nfs-server-provisioner" {
  metadata {
    name = "nfs-server-provisioner"
  }
}

resource "helm_release" "nfs-server-provisioner" {
  name = "nfs-server-provisioner"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "nfs-server-provisioner"
  namespace = kubernetes_namespace.nfs-server-provisioner.metadata[0].name

  values = [yamlencode(local.values)]
}
