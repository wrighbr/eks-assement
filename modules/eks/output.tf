data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.aws_eks.name
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority
}

output "openid_arn" {
  value = aws_iam_openid_connect_provider.cluster.id
}

output "openid_url" {
  value = aws_iam_openid_connect_provider.cluster.url
}
