variable "cluster_id" {
  type = string
}
variable "kube_version" {
  type = string
  default = "1.15"
}
variable "location_subnets" {
  type = list(object({
    id = string
    zone = string
  }))
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
