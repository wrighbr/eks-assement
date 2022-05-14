module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

module "eks" {
  source        = "./modules/eks"
  cluster_name  = var.cluster_name
  cluster_arn   = module.iam.cluster_role_arn
  node_role_arn = module.iam.nodes_role_arn
  subnet_ids    = var.subnet_ids
}

module "alb" {
  source       = "./modules/alb"
  cluster_name = var.cluster_name
  openid_arn   = module.eks.openid_arn
  openid_url   = module.eks.openid_url

  # providers = {
  #   "gavinbunney/kubectl" = "gavinbunney/kubectl"
  # }
}

