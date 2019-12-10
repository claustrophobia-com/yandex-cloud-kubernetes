output "load_balancer_ip" {
  value = data.kubernetes_service.nginx-ingress.load_balancer_ingress[0].ip
}
