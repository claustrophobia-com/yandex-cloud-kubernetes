module "operator" {
  source = "./modules/operator"
}
resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
}
module "cluster" {
  source = "./modules/cluster"

  cluster_name = var.cluster_name
  node_selector = var.node_selector
  scale = var.scale
  storage_class = var.storage_class
  storage_size = var.storage_size
  namespace = kubernetes_namespace.elasticsearch.metadata[0].name
}
locals {
  elasticsearch_username = keys(module.cluster.elasticsearch_user)[0]
  elasticsearch_password = values(module.cluster.elasticsearch_user)[0]
}
module "kibana" {
  source = "./modules/kibana"

  cluster_name = var.cluster_name
  node_selector = var.node_selector
  namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  ingress = var.kibana_ingress
}
module "logstash" {
  source = "./modules/logstash"

  namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  elasticsearch_host = module.cluster.elasticsearch_host
  elasticsearch_username = local.elasticsearch_username
  elasticsearch_password = local.elasticsearch_password
  node_selector = var.node_selector
  scale = var.scale
}
module "filebeat" {
  source = "./modules/filebeat"

  namespace = kubernetes_namespace.elasticsearch.metadata[0].name
  logstash_host = module.logstash.logstash_host
  logstash_port = module.logstash.input_ports["beats"]
}
