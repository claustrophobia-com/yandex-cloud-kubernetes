variable "node_selector" {
  type = map(string)
}
variable "ingress" {
  type = object({
    name = string
    issuer = string
    domain = string
  })
}
