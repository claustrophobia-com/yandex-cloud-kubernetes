output "cluster_instances" {
  value = module.cluster.instances
}
output "load_balancer_ip" {
  value = module.nginx-ingress.load_balancer_ip
}
output "elasticsearch_host" {
  value = module.elasticsearch.elasticsearch_host
}
output "elasticsearch_user" {
  value = module.elasticsearch.elasticsearch_user
}
output "grafana_admin_password" {
  value = module.prometheus.grafana_admin_password
}
output "container_registry_id" {
  value = module.registry.registry_id
}
output "prometheus_admin_password" {
  value = module.prometheus.prometheus_admin_password
}
