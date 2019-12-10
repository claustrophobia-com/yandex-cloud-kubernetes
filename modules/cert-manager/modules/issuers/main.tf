locals {
  issuers = {
    staging = {
      kind = "ClusterIssuer"
      apiVersion = "cert-manager.io/v1alpha2"
      metadata = {
        name = "letsencrypt-staging"
      }
      spec = {
        acme = {
          server = "https://acme-staging-v02.api.letsencrypt.org/directory"
          email = var.staging_email
          privateKeySecretRef = {
            name = "letsencrypt-staging"
          }
          solvers = [
            {
              http01 = {
                ingress = {
                  class = "nginx"
                }
              }
            }
          ]
        }
      }
    }
    production = {
      kind = "ClusterIssuer"
      apiVersion = "cert-manager.io/v1alpha2"
      metadata = {
        name = "letsencrypt-production"
      }
      spec = {
        acme = {
          server = "https://acme-v02.api.letsencrypt.org/directory"
          email = var.production_email
          privateKeySecretRef = {
            name = "letsencrypt-production"
          }
          solvers = [
            {
              http01 = {
                ingress = {
                  class = "nginx"
                }
              }
            }
          ]
        }
      }
    }
  }
}

resource "kubectl_manifest" "issuers" {
  for_each = local.issuers
  yaml_body = yamlencode(each.value)
}
