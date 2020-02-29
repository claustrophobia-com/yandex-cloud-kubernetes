resource "yandex_kubernetes_node_group" "cluster_node_groups" {
  for_each = var.cluster_node_groups

  name = each.value["name"]
  description = each.value["name"]

  version = var.kube_version

  cluster_id = var.cluster_id

  labels = {
    "group_name" = each.value["name"]
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
    dynamic "auto_scale" {
      for_each = each.value["auto_scale"]
      content {
        min = auto_scale.value["min"]
        max = auto_scale.value["max"]
        initial = auto_scale.value["initial"]
      }
    }
    dynamic "fixed_scale" {
      for_each = each.value["fixed_scale"]
      content {
        size = fixed_scale.value
      }
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
