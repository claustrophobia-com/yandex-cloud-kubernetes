variable "cluster_id" {}
variable "kube_version" {}
variable "location_subnets" {}
variable "cluster_node_types" {
  default = {
    ingress = {
      cpu = 2
      memory = 2
      disk_size = 64
      scale = 2
    }
//    web = {
//      cpu = 4
//      memory = 8
//      disk_size = 20
//    }
//    ci = {
//      cpu = 4
//      memory = 16
//      disk_size = 20
//    }
  }
}
