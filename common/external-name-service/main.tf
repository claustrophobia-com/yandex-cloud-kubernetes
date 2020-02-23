resource "kubernetes_service" "service" {
  metadata {
    name = var.name
    namespace = var.namespace
  }
  spec {
    type = "ExternalName"
    external_name = var.external_name
  }
}
