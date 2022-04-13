variable "ARM_CLIENT_ID" {
  type        = string
  description = "Check in .env"
}

variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "Check in .env"
}


variable "ARM_TENANT_ID" {
  type        = string
  description = "Check in .env"
}


variable "SECRET_VALUE" {
  type        = string
  description = "Check in .env"
}


variable "GLOBAL_LOCATION" {
  type    = string
  default = "North Europe"
}



variable "GLOBAL_VNET_CIDR" {
  type    = string
  default = "10.0.0.0/16"
}


variable "GLOBAL_DNS_SERVERS" {
  type = map(string)
  default = {
    "a" = "1.1.1.1",
    "b" = "8.8.8.8",
    "c" = "8.8.4.4"
  }
}


variable "GLOBAL_VNET_SUBNETS" {
  type = map(any)
  default = {
    a      = "10.0.1.0/24",
    aks    = "10.0.64.0/20"
    aksSvc = "10.0.224.0/20"
  }
}

variable "GLOBAL_K8S_DNS_IP" {
  type    = string
  default = "10.0.239.250"
}
variable "GLOBAL_K8S_DOCKER_IP" {
  type    = string
  default = "10.0.239.200"
}


variable "GLOBAL_RESOURCENAME_PREFIX" {
  type    = string
  default = "en1tstkk99-"
}
variable "GLOBAL_RESOURCENAME_PREFIX_ALPHANUM" {
  type    = string
  default = "en1tstkk99"
}


variable "vm1_host_user" {
  type    = string
  default = "user"
}

variable "vm1_host_password" {
  type    = string
  default = "Pass123"
}

variable "k8s_kubeconfig" {
  type    = string
  default = "./output/kubeconfig"
}

variable "k8s_nodes_resource_group_name" {
  type    = string
  default = "en1tstkk99k8snodes"
}