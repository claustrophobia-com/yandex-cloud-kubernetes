data "local_file" "all_in_one_manifest" {
  filename = "${path.module}/sources/all-in-one.yaml"
}
locals {
  all_in_one = split("\n---\n", trimsuffix(data.local_file.all_in_one_manifest.content, "\n"))
}
resource "kubectl_manifest" "all_in_one" {
  count = length(local.all_in_one)
  yaml_body = local.all_in_one[count.index]
}
