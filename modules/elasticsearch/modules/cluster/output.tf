output "elasticsearch_host" {
  value = "${var.cluster_name}-es-http.${var.namespace}"
}

output "elasticsearch_user" {
  value = data.kubernetes_secret.elastic-user.data
}
