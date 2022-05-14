resource "kubectl_manifest" "ingress_controller" {
  yaml_body = templatefile("${path.module}/deployment.tftpl", { host = var.host })
}
