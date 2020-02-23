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
  filters = {
    type = <<-EOF
    filter {
      mutate {
        add_field => {
          "type" => "%%{[agent][type]}"
        }
      }
    }
    EOF
    nginx = <<-EOF
    filter {
      if [event][module] == "nginx" {
        if [fileset][name] == "access" {
          grok {
            match => { "message" => ["%%{IPORHOST:[nginx][access][remote_ip]} - %%{DATA:[nginx][access][user_name]} \[%%{HTTPDATE:[nginx][access][time]}\] \"%%{WORD:[nginx][access][method]} %%{DATA:[nginx][access][url]} HTTP/%%{NUMBER:[nginx][access][http_version]:float}\" %%{NUMBER:[nginx][access][response_code]:int} %%{NUMBER:[nginx][access][body_sent][bytes]:int} \"%%{DATA:[nginx][access][referrer]}\" \"%%{DATA:[nginx][access][agent]}\" %%{NUMBER:[nginx][access][request_length]:int} %%{NUMBER:[nginx][access][request_time]:float} \[%%{DATA:[nginx][access][proxy_upstream_name]}\] \[%%{DATA:[nginx][access][proxy_alternative_upstream_name]}\] %%{DATA:[nginx][access][upstream_addr]} %%{NUMBER:[nginx][access][upstream_response_length]:int} %%{NUMBER:[nginx][access][upstream_response_time]:float} %%{NUMBER:[nginx][access][upstream_status]:int} %%{DATA:[nginx][access][req_id]}"] }
            remove_field => "message"
          }
          mutate {
            add_field => { "read_timestamp" => "%%{@timestamp}" }
          }
          date {
            match => [ "[nginx][access][time]", "dd/MMM/YYYY:H:m:s Z" ]
            remove_field => "[nginx][access][time]"
          }
          useragent {
            source => "[nginx][access][agent]"
            target => "[nginx][access][user_agent]"
            remove_field => "[nginx][access][agent]"
          }
          geoip {
            source => "[nginx][access][remote_ip]"
            target => "[nginx][access][geoip]"
          }
        }
        else if [fileset][name] == "error" {
          grok {
            match => { "message" => ["%%{DATA:[nginx][error][time]} \[%%{DATA:[nginx][error][level]}\] %%{NUMBER:[nginx][error][pid]}#%%{NUMBER:[nginx][error][tid]}: (\*%%{NUMBER:[nginx][error][connection_id]} )?%%{GREEDYDATA:[nginx][error][message]}"] }
            remove_field => "message"
          }
          mutate {
            rename => { "@timestamp" => "read_timestamp" }
          }
          date {
            match => [ "[nginx][error][time]", "YYYY/MM/dd H:m:s" ]
            remove_field => "[nginx][error][time]"
          }
        }
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
    inputs = merge(local.inputs, { main = "" })
    filters = local.filters
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
  version = ""
  namespace = var.namespace
  timeout = 600

  values = [yamlencode(local.values)]
}
