variable "namespace" {
  type = string
}
variable "node_selector" {
  type = map(string)
}
variable "scale" {
  type = number
}
variable "elasticsearch_host" {
  type = string
}
variable "elasticsearch_username" {
  type = string
}
variable "elasticsearch_password" {
  type = string
}
