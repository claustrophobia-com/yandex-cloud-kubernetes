variable "name" {}
variable "public" {}
variable "region" {
  default = "ru-central1"
}
variable "kube_version" {}
variable "release_channel" {}
variable "vpc_id" {}
variable "location_subnets" {}
variable "cluster_service_account_id" {
  type = string
}
variable "node_service_account_id" {
  type = string
}
