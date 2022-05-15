terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}


provider "aws" {
  region = "ap-southeast-2"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    token                  = module.eks.cluster_token
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority.0.data)
  }
}


provider "kubectl" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority.0.data)
  token                  = module.eks.cluster_token
  load_config_file       = false
}
