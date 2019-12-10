output "logstash_host" {
  value = "logstash.${var.namespace}"
}
output "input_ports" {
  value = local.input_ports
}
