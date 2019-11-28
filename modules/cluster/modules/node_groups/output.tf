output "instances" {
  value = {
    for type in keys(var.cluster_node_types):
      type => [
        for instance in data.yandex_compute_instance_group.cluster_instance_group[index(keys(var.cluster_node_types), type)].instances:
          {
            private_ip = instance.network_interface.0.ip_address
            public_ip = instance.network_interface.0.nat_ip_address
          }
      ]
  }
}
