output "instances" {
  value = {
    for type, group in data.yandex_compute_instance_group.cluster_instance_groups:
      type =>
      [
        for instance in group["instances"]:
          {
            private_ip = instance.network_interface.0.ip_address
            public_ip = instance.network_interface.0.nat_ip_address
          }
      ]
  }
}
output "node_group_ids" {
  value = {
    for group in yandex_kubernetes_node_group.cluster_node_groups:
      group.name => group.id
  }
}
