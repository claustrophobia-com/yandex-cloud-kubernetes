data "yandex_resourcemanager_folder" "cluster_folder" {
  folder_id = var.cluster_folder_id
}

resource "yandex_iam_service_account" "cluster" {
  name = var.cluster_service_account_name
}

resource "yandex_resourcemanager_folder_iam_member" "cluster-admin" {
  folder_id = data.yandex_resourcemanager_folder.cluster_folder.id
  role   = "editor"
  member = "serviceAccount:${yandex_iam_service_account.cluster.id}"
}

resource "yandex_iam_service_account" "cluster_node" {
  name = var.cluster_node_service_account_name
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_node-admin" {
  folder_id = data.yandex_resourcemanager_folder.cluster_folder.id
  role   = "container-registry.images.puller"
  member = "serviceAccount:${yandex_iam_service_account.cluster_node.id}"
}
