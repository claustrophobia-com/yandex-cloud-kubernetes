resource "kubernetes_secret" "opaque" {
  for_each = var.opaque_secrets
  metadata {
    name = each.key
    namespace = var.namespace
  }
  data = each.value
  type = "Opaque"
}
