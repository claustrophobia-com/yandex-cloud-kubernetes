provider "yandex" {
  token = var.yandex_token
  cloud_id = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}

locals {
  cluster_service_account_name = "${var.cluster_name}-cluster"
  cluster_node_service_account_name = "${var.cluster_name}-node"
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
}
