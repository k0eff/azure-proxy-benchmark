terraform {
  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = var.k8sHost
  cluster_ca_certificate = var.k8sCA
  token                  = var.k8sToken
}