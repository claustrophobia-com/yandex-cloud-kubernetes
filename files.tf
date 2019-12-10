resource "local_file" "kubeconfigs" {
  for_each = module.admins.kubeconfigs
  filename = "${var.output_dir}/kubeconfigs/${each.key}.yaml"
  file_permission = "0600"
  directory_permission = "0700"
  sensitive_content = yamlencode(each.value)
}
