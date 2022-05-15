resource "null_resource" "deploy_ingress_controller" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command     = <<EOT
      aws eks --region ap-southeast-2 update-kubeconfig --name "${var.cluster_name}"
      kubectl apply -f ${path.module}/deploy.yaml
EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
