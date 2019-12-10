output "storage_class" {
  value = jsondecode(helm_release.nfs-server-provisioner.metadata[0].values)["storageClass"]["name"]
}
