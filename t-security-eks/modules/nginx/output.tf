output "service_endpoint" {
  description = "LoadBalancer endpoint for nginx service"
  value = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname
}