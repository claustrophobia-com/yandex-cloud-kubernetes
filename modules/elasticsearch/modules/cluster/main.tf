locals {
  nodeSelectorPodTemplateSpec = {
    nodeSelector = var.node_selector
  }
  emptyDirPodTemplateSpec = {
    volumes = [
      {
        name = "elasticsearch-data"
        emptyDir = {}
      }
    ]
  }
  cluster = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1beta1"
    kind = "Elasticsearch"
    metadata = {
      name = var.cluster_name
      namespace = var.namespace
    }
    spec = {
      version = "7.5.0"
      nodeSets = [
        {
          name = "master"
          count = var.scale
          podTemplate = {
            spec = merge(local.nodeSelectorPodTemplateSpec, local.emptyDirPodTemplateSpec)
          }
          config = {
            "node.master" = true
            "node.data" = false
            "node.ingest" = false
            "node.store.allow_mmap" = true
          }
        },
        {
          name = "data"
          count = var.scale
          podTemplate = {
            spec = local.nodeSelectorPodTemplateSpec
          }
          volumeClaimTemplates = [
            {
              metadata = {
                name = "elasticsearch-data"
              }
              spec = {
                accessModes = [
                  "ReadWriteOnce"
                ]
                resources = {
                  requests = {
                    storage = var.storage_size
                  }
                }
              }
              storageClassName: var.storage_class
            }
          ]
          config = {
            "node.master" = false
            "node.data" = true
            "node.ingest" = false
            "node.store.allow_mmap" = true
          }
        },
        {
          name = "ingest"
          count = var.scale
          podTemplate = {
            spec = merge(local.nodeSelectorPodTemplateSpec, local.emptyDirPodTemplateSpec)
          }
          config = {
            "node.master" = false
            "node.data" = false
            "node.ingest" = true
            "node.store.allow_mmap" = true
          }
        }
      ]
      http = {
        tls = {
          selfSignedCertificate = {
            disabled = true
          }
        }
      }
    }
  }

}

resource "kubectl_manifest" "cluster" {
  yaml_body = yamlencode(local.cluster)
}

data "kubernetes_secret" "elastic-user" {
  metadata {
    name = "${var.cluster_name}-es-elastic-user"
    namespace = var.namespace
  }
  depends_on = [kubectl_manifest.cluster]
}
