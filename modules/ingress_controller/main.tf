resource "kubectl_manifest" "ingress_controller" {
  yaml_body = file("${path.module}/deploy.yaml")
}
