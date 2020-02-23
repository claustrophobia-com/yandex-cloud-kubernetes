variable "dep" {
  default = []
}
output "req" {
  value = [kubectl_manifest.issuers]
}
