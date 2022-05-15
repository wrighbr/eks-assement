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
    command     = "eksctl create iamserviceaccount --name external-dns --namespace external-dns --cluster ${var.cluster_name} --attach-policy-arn ${aws_iam_policy.external_dns.arn} --override-existing-serviceaccounts --approve"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "kubectl_manifest" "external_dns_cluster_role" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get","watch","list"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get","watch","list"]
  - apiGroups: ["networking","networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get","watch","list"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get","watch","list"]
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get","watch","list"]
YAML
}

resource "kubectl_manifest" "external_dns_cluster_role_binding" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: default
YAML
}

resource "kubectl_manifest" "external_dns_deployment" {
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.10.2
        args:
        - --source=service
        - --source=ingress
        - --domain-filter=${var.domain_filter}  # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=aws
        - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=${var.zone_id}
YAML
}
