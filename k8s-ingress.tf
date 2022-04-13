resource "helm_release" "nginxIngress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.13"
  depends_on = [
    azurerm_kubernetes_cluster.k8sCMain
  ]

  set {
    name  = "namespace"
    value = "nginx-ingress"
  }

  set {
    name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.k8sIngressIp.ip_address
  }

  set {
    name  = "controller.service.annotations.service.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = azurerm_resource_group.rgMain.name
  }
}