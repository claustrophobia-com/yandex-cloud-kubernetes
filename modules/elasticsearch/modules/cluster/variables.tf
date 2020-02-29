variable "node_selector" {
  type = map(string)
}
variable "scale" {
  type = number
}
variable "cluster_name" {
  type = string
}
variable "storage_class" {
  type = string
}
variable "storage_size" {
  type = string
}
variable "namespace" {
  type = string
}
