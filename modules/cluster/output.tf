output "instances" {
  value = module.node_groups.instances
}
output "node_group_ids" {
  value = module.node_groups.node_group_ids
}
output "external_v4_endpoint" {
  value = yandex_kubernetes_cluster.cluster.master[0].external_v4_endpoint
}
output "ca_certificate" {
  value = yandex_kubernetes_cluster.cluster.master[0].cluster_ca_certificate
}
