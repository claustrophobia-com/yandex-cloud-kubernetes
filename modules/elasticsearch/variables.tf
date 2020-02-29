variable "cluster_name" {
  type = string
}
variable "node_selector" {
  type = map(string)
}
variable "scale" {
  type = number
}
variable "storage_class" {
  type = string
}
variable "storage_size" {
  type = string
}
variable "kibana_ingress" {
  type = object({
    name = string
    issuer = string
    domain = string
  })
}
