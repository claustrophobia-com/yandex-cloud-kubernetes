variable "name" {
  type = string
}
variable "public" {
  type = bool
  default = true
}
variable "region" {
  type = string
  default = "ru-central1"
}
variable "kube_version" {
  type = string
  default = "1.15"
}
variable "release_channel" {
  type = string
  default = "STABLE"
}
variable "vpc_id" {
  type = string
}
variable "location_subnets" {
  type = list(object({
    id = string
    zone = string
  }))
}
variable "cluster_service_account_id" {
  type = string
}
variable "node_service_account_id" {
  type = string
}
variable "cluster_node_groups" {
  type = map(object({
    name = string
    cpu = number
    memory = number
    disk = object({
      size = number
      type = string
    })
    fixed_scale = list(number)
    auto_scale = list(object({
      max = number
      min = number
      initial = number
    }))
  }))
}
variable "ssh_keys" {
  type = string
}
