data "http" "crds_manifest" {
  url = "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml"
}

locals {
  crds = split("\n---\n", trimsuffix(data.http.crds_manifest.body, "\n---\n"))
}

resource "kubectl_manifest" "crds" {
  count = length(local.crds)
  yaml_body = local.crds[count.index]
}
