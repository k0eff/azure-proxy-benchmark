resource "azurerm_kubernetes_cluster" "k8sCMain" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}aks"
  resource_group_name = azurerm_resource_group.rgMain.name
  location            = azurerm_resource_group.rgMain.location
  dns_prefix          = "${var.GLOBAL_RESOURCENAME_PREFIX}aks"

  default_node_pool {
    name           = "aksnp00"
    node_count     = 1
    vm_size        = "Standard_D2_v3"
    vnet_subnet_id = azurerm_subnet.subnetAks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = var.GLOBAL_VNET_SUBNETS.aksSvc
    dns_service_ip     = var.GLOBAL_K8S_DNS_IP
    docker_bridge_cidr = var.GLOBAL_K8S_DOCKER_IP
    load_balancer_sku  = "standard"
  }

  node_resource_group = var.k8s_nodes_resource_group_name
}

data "azurerm_resource_group" "rgK8sNodes" {
  name = var.k8s_nodes_resource_group_name
  depends_on = [
    azurerm_kubernetes_cluster.k8sCMain
  ]
}

resource "azurerm_public_ip" "k8sIngressIp" {
  name                = "k8sIngressIp"
  location            = data.azurerm_resource_group.rgK8sNodes.location
  resource_group_name = var.k8s_nodes_resource_group_name # k8s nodes resource group name; and it's location should match cluster resource group's location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
}

output "clientCertificate" {
  value     = azurerm_kubernetes_cluster.k8sCMain.kube_config_raw
  sensitive = true
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.k8sCMain.kube_config_raw
  sensitive = true
}

output "kubeconfigTf" {
  value     = azurerm_kubernetes_cluster.k8sCMain.kube_config
  sensitive = true
}

resource "azurerm_kubernetes_cluster_node_pool" "k8sNP01" {
  name                  = "aksnp01"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8sCMain.id
  vnet_subnet_id        = azurerm_subnet.subnetAks.id
  vm_size               = "Standard_D2_v3"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 10
  max_pods              = 30
  zones                 = ["1"]
}

resource "null_resource" "k8sKubeconfigOutput" {
  provisioner "local-exec" {
    command = local.kubeConfigCmd
  }
  triggers = {
    kubeconfig = md5(azurerm_kubernetes_cluster.k8sCMain.kube_config_raw)
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8sCMain
  ]
}

locals {
  kubeConfigCmd = <<EOF
cat <<ECAT > ${var.k8s_kubeconfig}
${azurerm_kubernetes_cluster.k8sCMain.kube_config_raw}
ECAT
EOF
}

module "k8sYaml" {
  source   = "./k8s-yaml"
  k8sToken = yamldecode(azurerm_kubernetes_cluster.k8sCMain.kube_config_raw).users[0].user.token
  k8sHost  = azurerm_kubernetes_cluster.k8sCMain.kube_config.0.host
  k8sCA    = base64decode(azurerm_kubernetes_cluster.k8sCMain.kube_config.0.cluster_ca_certificate)
}