provider "yandex" {
  token = var.yandex_token
  cloud_id = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}

locals {
  cluster_service_account_name = "${var.cluster_name}-cluster"
  cluster_node_service_account_name = "${var.cluster_name}-node"

  cluster_node_group_configs = {
    service = {
      name = "service"
      cpu = 6
      memory = 18
      disk = {
        size = 64
        type = "network-ssd"
      }
    }
    nfs = {
      name = "nfs"
      cpu = 2
      memory = 2
      disk = {
        size = 64
        type = "network-ssd"
      }
    }
    web = {
      name = "web"
      cpu = 6
      memory = 12
      disk = {
        size = 64
        type = "network-ssd"
      }
    }
  }
  cluster_node_groups = {
    for key, config in local.cluster_node_group_configs:
      key => merge(config, {
        fixed_scale = lookup(var.node_groups_scale[key], "fixed_scale", false) != false ? [var.node_groups_scale[key].fixed_scale] : []
        auto_scale = lookup(var.node_groups_scale[key], "auto_scale", false) != false ? [var.node_groups_scale[key].auto_scale] : []
      })
  }
  node_selectors = {
    for key, id in module.cluster.node_group_ids:
      key => {
        "yandex.cloud/node-group-id" = id
      }
  }
  hosts = {
    dashboard = {
      name = "k8s"
      issuer = module.cert-manager.cluster_issuers["production"]
    }
    kibana = {
      name = "kb"
      issuer = module.cert-manager.cluster_issuers["production"]
    }
    alertmanager = {
      name = "alerts"
      issuer = module.cert-manager.cluster_issuers["production"]
    }
    prometheus = {
      name = "metrics"
      issuer = module.cert-manager.cluster_issuers["production"]
    }
    grafana = {
      name = "stats"
      issuer = module.cert-manager.cluster_issuers["production"]
    }
  }
  ingress = {
    for key, host in local.hosts:
      key => merge(host, { domain = "${host.name}.${var.cluster_domain}" })
  }
  elasticsearch_username = keys(module.elasticsearch.elasticsearch_user)[0]
  elasticsearch_password = module.elasticsearch.elasticsearch_user[local.elasticsearch_username]
  elasticsearch_url = "http://${local.elasticsearch_username}:${local.elasticsearch_password}@${module.elasticsearch.elasticsearch_host}:9200"
}

module "vpc" {
  source = "./modules/vpc"

  name = var.cluster_name
}

module "iam" {
  source = "./modules/iam"

  cluster_folder_id = var.yandex_folder_id
  cluster_service_account_name = local.cluster_service_account_name
  cluster_node_service_account_name = local.cluster_node_service_account_name
}

module "cluster" {
  source = "./modules/cluster"

  name = var.cluster_name
  public = true
  kube_version = var.cluster_version
  release_channel = var.cluster_release_channel
  vpc_id = module.vpc.vpc_id
  location_subnets = module.vpc.location_subnets
  cluster_service_account_id = module.iam.cluster_service_account_id
  node_service_account_id = module.iam.cluster_node_service_account_id
  cluster_node_groups = local.cluster_node_groups
  ssh_keys = module.admins.ssh_keys
  dep = [
    module.iam.req
  ]
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host = module.cluster.external_v4_endpoint
    cluster_ca_certificate = module.cluster.ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "${path.root}/yc-cli/bin/yc"
      args = [
        "managed-kubernetes",
        "create-token",
        "--cloud-id", var.yandex_cloud_id,
        "--folder-id", var.yandex_folder_id,
        "--token", var.yandex_token,
      ]
    }
  }
}

provider "kubernetes" {
  load_config_file = false

  host = module.cluster.external_v4_endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "${path.root}/yc-cli/bin/yc"
    args = [
      "managed-kubernetes",
      "create-token",
      "--cloud-id", var.yandex_cloud_id,
      "--folder-id", var.yandex_folder_id,
      "--token", var.yandex_token,
    ]
  }
}

module "nginx-ingress" {
  source = "./modules/nginx-ingress"

  node_selector = local.node_selectors["web"]
}

provider "kubectl" {
  load_config_file = false

  host = module.cluster.external_v4_endpoint
  cluster_ca_certificate = module.cluster.ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "${path.root}/yc-cli/bin/yc"
    args = [
      "managed-kubernetes",
      "create-token",
      "--cloud-id", var.yandex_cloud_id,
      "--folder-id", var.yandex_folder_id,
      "--token", var.yandex_token,
    ]
  }
}

provider "http" {}

module "cert-manager" {
  source = "./modules/cert-manager"

  issuers_email = var.admin_email

  node_selector = local.node_selectors["service"]

}

module "kubernetes-dashboard" {
  source = "./modules/kubernetes-dashboard"

  node_selector = local.node_selectors["service"]

  ingress = local.ingress["dashboard"]
}

module "admins" {
  source = "./modules/admins"

  admins = var.admins
  cluster_name = var.cluster_name
  cluster_endpoint = module.cluster.external_v4_endpoint
}

provider "local" {}

provider "random" {}

module "nfs-server-provisioner" {
  source = "./modules/nfs-server-provisioner"

  node_selector = local.node_selectors["nfs"]
  storage_class = "yc-network-ssd"
  storage_size = "200Gi"
}

module "registry" {
  source = "./modules/registry"

  registry_name = var.cluster_name
}

module "elasticsearch" {
  source = "./modules/elasticsearch"

  cluster_name = var.cluster_name
  node_selector = local.node_selectors["service"]
  scale = lookup(var.node_groups_scale["service"], "fixed_scale", 3)
  storage_class = "yc-network-ssd"
  storage_size = "50Gi"
  kibana_ingress = local.ingress["kibana"]
}

module "prometheus" {
  source = "./modules/prometheus"

  configs = {
    alertmanager = {
      ingress = local.ingress["alertmanager"]
      node_selector = local.node_selectors["service"]
      storage_class = module.nfs-server-provisioner.storage_class
      storage_mode = "ReadWriteMany"
      storage_size = "2Gi"
    }
    grafana = {
      ingress = local.ingress["grafana"]
      http_auth = false
    }
    operator = {
      node_selector = local.node_selectors["service"]
    }
    prometheus = {
      node_selector = local.node_selectors["service"]
      ingress = local.ingress["prometheus"]
      storage_class = module.nfs-server-provisioner.storage_class
      storage_mode = "ReadWriteMany"
      storage_size = "2Gi"
    }
  }
}
