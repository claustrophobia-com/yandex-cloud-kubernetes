data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

locals {
  values = {
    config = {
      output = {
        logstash = {
          hosts = ["${var.logstash_host}:${var.logstash_port}"]
        }
        file = {
          enabled = false
        }
      }
    }
  }
}

resource "helm_release" "filebeat" {
  name = "filebeat"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "filebeat"
  namespace = var.namespace

  values = [yamlencode(local.values)]
}
