variable "admins" {
  type = map(object({
    public_keys = list(string)
  }))
}
variable "cluster_name" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
