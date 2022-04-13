terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.93.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "= 2.14.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "= 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = var.ARM_SUBSCRIPTION_ID
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.SECRET_VALUE
  tenant_id       = var.ARM_TENANT_ID
}


provider "helm" {
  kubernetes {
    host                   = try(azurerm_kubernetes_cluster.k8sCMain.kube_config.0.host, "")
    client_certificate     = base64decode(try(azurerm_kubernetes_cluster.k8sCMain.kube_config.0.client_certificate, ""))
    cluster_ca_certificate = base64decode(try(azurerm_kubernetes_cluster.k8sCMain.kube_config.0.cluster_ca_certificate, ""))
    client_key             = base64decode(try(azurerm_kubernetes_cluster.k8sCMain.kube_config.0.client_key, ""))
  }
}

resource "azurerm_resource_group" "rgMain" {
  name     = "${var.GLOBAL_RESOURCENAME_PREFIX}rg"
  location = var.GLOBAL_LOCATION
}
