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

module "ingress_controller" {
  source = "./modules/ingress_controller"
}

module "deployment" {
  source = "./modules/deployment"
  host   = var.host
}
