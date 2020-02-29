variable "cluster_name" {
  type = string
}
variable "node_selector" {
  type = map(string)
}
variable "namespace" {
  type = string
}
variable "ingress" {
  type = object({
    name = string
    issuer = string
    domain = string
  })
}
