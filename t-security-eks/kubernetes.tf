# Wait for cluster to be ready
resource "time_sleep" "wait_eks" {
  depends_on      = [module.eks]
  create_duration = "90s"
}

# Update kubeconfig
resource "null_resource" "update_kubeconfig" {
  depends_on = [time_sleep.wait_eks]

  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${local.cluster_name}"
  }
}

# Verify cluster access
resource "null_resource" "verify_kubectl" {
  depends_on = [null_resource.update_kubeconfig]

  provisioner "local-exec" {
    command = "kubectl get nodes"
  }
}

module "nginx" {
  source = "./modules/nginx"

  providers = {
    kubernetes = kubernetes
  }

  depends_on = [
    null_resource.verify_kubectl,
    time_sleep.wait_eks
  ]
}

output "nginx_endpoint" {
  description = "LoadBalancer endpoint for nginx service"
  value       = try(module.nginx.service_endpoint, "Waiting for LoadBalancer...")
}