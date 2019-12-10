locals {
  usernames = keys(var.admins)
  ssh_keys = flatten([
    for admin, config in var.admins: [
      for key in config["public_keys"]: [
        format("%s:%s %s", admin, key, admin)
      ]
    ]
  ])

}
resource "kubernetes_service_account" "admin" {
  for_each = toset(local.usernames)
  metadata {
    namespace = "default"
    name = each.key
  }
}
resource "kubernetes_cluster_role_binding" "admin" {
  for_each = kubernetes_service_account.admin
  metadata {
    name = each.key
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    api_group = ""
    kind = "ServiceAccount"
    name = each.key
    namespace = "default"
  }
}
data "kubernetes_secret" "admin" {
  for_each = kubernetes_service_account.admin
  metadata {
    name = each.value.default_secret_name
  }
}
locals {
  kubeconfigs = {
    for username, secret in data.kubernetes_secret.admin:
      username => {
        apiVersion = "v1"
        kind = "Config"
        clusters = [
          {
            name = var.cluster_name
            cluster = {
              certificate-authority-data = base64encode(secret.data["ca.crt"])
              server = var.cluster_endpoint
            }
          }
        ]
        users = [
          {
            name = username
            user = {
              token = secret.data["token"]
            }
          }
        ]
        contexts = [
          {
            name = var.cluster_name
            context = {
              cluster = var.cluster_name
              namespace = secret.data["namespace"]
              user = username
            }
          }
        ]
        current-context = var.cluster_name
        preferences = {}
      }
  }
}
