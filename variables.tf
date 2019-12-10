variable "yandex_token" {}
variable "yandex_cloud_id" {}
variable "yandex_folder_id" {}
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "cluster_release_channel" {
  type = string
}
variable "node_groups_scale" {}
variable "admin_email" {}
variable "cluster_domain" {}
variable "admins" {}
variable "output_dir" {
  default = "output"
}
variable "secret_dir" {
  default = "secrets"
}
variable "service_email" {}
