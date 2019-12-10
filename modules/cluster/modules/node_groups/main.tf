resource "yandex_kubernetes_node_group" "cluster_node_groups" {
  for_each = var.cluster_node_groups
  name = each.key
  version = var.kube_version

  cluster_id = var.cluster_id

  labels = {
    "group_name" = each.key
  }

  instance_template {
    platform_id = "standard-v2"
    nat = true

    metadata = {
      ssh-keys = var.ssh_keys
    }

    resources {
      cores = each.value["cpu"]
      memory = each.value["memory"]
    }

    boot_disk {
      type = each.value["disk"]["type"]
      size = each.value["disk"]["size"]
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = each.value["scale"]
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

data "yandex_compute_instance_group" "cluster_instance_groups" {
  for_each = yandex_kubernetes_node_group.cluster_node_groups
  instance_group_id = each.value.instance_group_id
}
