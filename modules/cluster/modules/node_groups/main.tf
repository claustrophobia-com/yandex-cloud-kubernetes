locals {
  node_types_name = keys(var.cluster_node_types)
  node_types_config = values(var.cluster_node_types)
}

resource "yandex_kubernetes_node_group" "cluster_node_group" {
  count = length(var.cluster_node_types)
  name = local.node_types_name[count.index]
  version = var.kube_version

  cluster_id = var.cluster_id

  instance_template {
    platform_id = "standard-v2"
    nat = true

    resources {
      cores = local.node_types_config[count.index].cpu
      memory = local.node_types_config[count.index].memory
    }

    boot_disk {
      type = "network-hdd"
      size = local.node_types_config[count.index].disk_size
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = local.node_types_config[count.index].scale
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = var.location_subnets

      content {
        zone = location.value.zone
        subnet_id = location.value.id
      }
    }
  }
}

data "yandex_kubernetes_node_group" "cluster_node_group" {
  count = length(var.cluster_node_types)
  node_group_id = yandex_kubernetes_node_group.cluster_node_group[count.index].id
}

data "yandex_compute_instance_group" "cluster_instance_group" {
  count = length(var.cluster_node_types)
  instance_group_id = element(data.yandex_kubernetes_node_group.cluster_node_group.*.instance_group_id, count.index)
}
