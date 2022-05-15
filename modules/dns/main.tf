resource "aws_iam_policy" "external_dns" {
  name        = "${var.cluster_name}-external-dns"
  path        = "/"
  description = "ExternalDNS IAM Policy for eks"

  policy = jsonencode(
    {
      Version : "2012-10-17"
      Statement : [
        {
          Effect : "Allow"
          Action : [
            "route53:ChangeResourceRecordSets"
          ]
          Resource : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          Effect : "Allow",
          Action : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          Resource : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "null_resource" "external_dns_service_account" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command     = <<EOT
eksctl create iamserviceaccount --name external-dns --namespace external-dns --cluster ${var.cluster_name} --attach-policy-arn ${aws_iam_policy.external_dns.arn} --override-existing-serviceaccounts --approve
EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# resource "null_resource" "deploy_ex" {
#   triggers = {
#     build_number = timestamp()
#   }
#   provisioner "local-exec" {
#     command     = <<EOT
#       aws eks --region ap-southeast-2 update-kubeconfig --name "${var.cluster_name}"
#       kubectl apply -f ${path.module}/deploy.yaml
# EOT
#     interpreter = ["/bin/bash", "-c"]
#   }
# }


# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "external-dns"
#   set {
#     name  = "provider"
#     value = "aws"
#   }
#   set {
#     name  = "domainFilters[0]"
#     value = var.domain_filter
#   }
#   set {
#     name  = "policy"
#     value = "sync"
#   }
#   set {
#     name  = "registry"
#     value = "txt"
#   }
#   set {
#     name  = "txtOwnerId"
#     value = var.zone_id
#   }
#   set {
#     name  = "rbac.create"
#     value = true
#   }
#   set {
#     name  = "rbac.serviceAccountName"
#     value = "external-dns"
#   }
#   set {
#     name = "rbac.serviceAccountAnnotations.eks\.amazonaws\.com/role-arn"
#     value = ""
#   }

#   depends_on = [
#     null_resource.external_dns_service_account
#   ]
# }
