output "node_group_ids" {
  value = {
    for group in yandex_kubernetes_node_group.cluster_node_groups:
      group.name => group.id
  }
}
