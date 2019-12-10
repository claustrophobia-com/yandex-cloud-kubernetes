output "grafana_admin_password" {
  value = random_string.grafana-password.result
}
output "prometheus_admin_password" {
  value = random_string.prometheus-password.result
}
