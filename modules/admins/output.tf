output "kubeconfigs" {
  value = local.kubeconfigs
}
output "ssh_keys" {
  value = join("\n", local.ssh_keys)
}
