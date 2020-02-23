data "helm_repository" "elastic" {
  name = "elastic"
  url = "https://helm.elastic.co/"
}

locals {
  values = {
    filebeatConfig = {
      "input-kubernetes.yml" = <<-EOF
      - type: container
        paths:
          - "/var/lib/docker/containers/*/*.log"
        processors:
          - add_kubernetes_metadata:
              in_cluster: true
          - drop_event:
              when:
                equals:
                  kubernetes.labels.app: nginx-ingress
        exclude_lines: ['kube-probe']
      EOF
      "filebeat.yml" = <<-EOF
      filebeat.modules:
        - module: nginx
      filebeat.config:
        inputs:
          path: $${path.config}/input-*.yml
          reload.enabled: false
        modules:
          path: $${path.config}/modules.d/*.yml
          reload.enabled: false
      filebeat.autodiscover:
        providers:
          - type: kubernetes
            templates:
              - condition:
                  equals:
                    kubernetes.labels.app: nginx-ingress
                config:
                  - module: nginx
                    access:
                      input:
                        type: container
                        stream: stdout
                        paths:
                          - "/var/lib/docker/containers/$${data.kubernetes.container.id}/*.log"
                    error:
                      input:
                        type: container
                        stream: stderr
                        paths:
                          - "/var/lib/docker/containers/$${data.kubernetes.container.id}/*.log"
      processors:
        - add_cloud_metadata:
      fields:
        logtype: kubernetes
      fields_under_root: true
      output.logstash:
        hosts: ["${var.logstash_host}:${var.logstash_port}"]
      EOF
    }
  }
}

resource "helm_release" "filebeat" {
  name = "filebeat"
  repository = data.helm_repository.elastic.metadata[0].name
  chart = "filebeat"
  version = "7.5.0"
  namespace = var.namespace

  values = [yamlencode(local.values)]
}
