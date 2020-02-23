data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}

locals {
  input_ports = {
    beats = 5044
    tcp = 5045
    udp = 5046
  }
  input_configs = {
    for name, port in local.input_ports:
      name => {
        port = port
        protocol = contains(["beats", "tcp"], name) ? "TCP" : "UDP"
        codec = contains(["tcp", "udp"], name) ? "json_lines" : false
      }
  }
  ports = [
    for name, config in local.input_configs:
    {
      name = name
      containerPort = config["port"]
      protocol = config["protocol"]
    }
  ]
  service_ports = {
    for name, config in local.input_configs:
      name => {
        targetPort = name
        port = config["port"]
        protocol = config["protocol"]
      }
  }
  inputs = {
    for name, config in local.input_configs:
      name => <<-EOF
      input {
        ${name} {
          port => ${config["port"]}%{ if config["codec"] != "false" }
          codec => ${config["codec"]}%{ endif }
        }
      }
      EOF
  }
  values = {
    nodeSelector = var.node_selector
    replicaCount = var.scale
    elasticsearch = {
      host = var.elasticsearch_host
    }
    service = {
      ports = local.service_ports
    }
    ports = local.ports
    inputs = local.inputs
    outputs = {
      main = <<-EOF
      output {
        elasticsearch {
          hosts => ["$${ELASTICSEARCH_HOST}:$${ELASTICSEARCH_PORT}"]
          user => "${var.elasticsearch_username}"
          password => "${var.elasticsearch_password}"

          manage_template => false
          index => "%%{type}-%%{+YYYY.MM.dd}"
        }
      }
      EOF
    }
  }
}

resource "helm_release" "logstash" {
  name = "logstash"
  repository = data.helm_repository.stable.metadata[0].name
  chart = "logstash"
  namespace = var.namespace

  values = [yamlencode(local.values)]
}
