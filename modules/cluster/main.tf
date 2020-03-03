resource "yandex_kubernetes_cluster" "cluster" {
  name = var.name

  network_id = var.vpc_id

  master {
    regional {
      region = var.region

      dynamic "location" {
        for_each = var.location_subnets

        content {
          zone = location.value.zone
          subnet_id = location.value.id
        }
      }
    }

    version = var.kube_version
    public_ip = var.public
  }

  service_account_id = var.cluster_service_account_id
  node_service_account_id = var.node_service_account_id

  release_channel = var.release_channel

  depends_on = [
    var.dep
  ]
}

module "node_groups" {
  source = "./modules/node_groups"

  cluster_id = yandex_kubernetes_cluster.cluster.id
  kube_version = var.kube_version
  location_subnets = var.location_subnets
  cluster_node_groups = var.cluster_node_groups
  ssh_keys = var.ssh_keys
}
