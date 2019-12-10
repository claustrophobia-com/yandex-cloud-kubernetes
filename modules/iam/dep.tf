variable "dep" {
  default = []
}
output "req" {
  value = [
    yandex_iam_service_account.cluster,
    yandex_iam_service_account.cluster_node,
    yandex_resourcemanager_folder_iam_member.cluster-admin,
    yandex_resourcemanager_folder_iam_member.cluster_node-admin,
  ]
}
