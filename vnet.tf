resource "azurerm_virtual_network" "vnetMain" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}vnet_main"
  location            = azurerm_resource_group.rgMain.location
  resource_group_name = azurerm_resource_group.rgMain.name
  address_space       = [var.GLOBAL_VNET_CIDR]
  dns_servers         = [var.GLOBAL_DNS_SERVERS.a, var.GLOBAL_DNS_SERVERS.b, var.GLOBAL_DNS_SERVERS.c]
}


resource "azurerm_subnet" "subnet1" {
  name                 = "${var.GLOBAL_RESOURCENAME_PREFIX}subnet_1"
  resource_group_name  = azurerm_resource_group.rgMain.name
  virtual_network_name = azurerm_virtual_network.vnetMain.name
  address_prefixes     = [var.GLOBAL_VNET_SUBNETS.a]
}

resource "azurerm_subnet" "subnetAks" {
  name                 = "${var.GLOBAL_RESOURCENAME_PREFIX}subnet_aks"
  resource_group_name  = azurerm_resource_group.rgMain.name
  virtual_network_name = azurerm_virtual_network.vnetMain.name
  address_prefixes     = [var.GLOBAL_VNET_SUBNETS.aks]
}


resource "azurerm_network_security_group" "sgMain" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}sg_main"
  location            = var.GLOBAL_LOCATION
  resource_group_name = azurerm_resource_group.rgMain.name
}

resource "azurerm_network_security_group" "sgAks" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}sg_aks"
  location            = azurerm_resource_group.rgMain.location
  resource_group_name = azurerm_resource_group.rgMain.name
}


resource "azurerm_network_security_rule" "rule80" {
  name                         = "${var.GLOBAL_RESOURCENAME_PREFIX}rule80_inb"
  priority                     = 150
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "80"
  source_address_prefix        = "*"
  destination_address_prefixes = flatten([azurerm_subnet.subnet1.address_prefixes])
  network_security_group_name  = azurerm_network_security_group.sgMain.name
  resource_group_name          = azurerm_resource_group.rgMain.name
}

resource "azurerm_network_security_rule" "rule30003" {
  name                         = "${var.GLOBAL_RESOURCENAME_PREFIX}rule30003_inb"
  priority                     = 155
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "30003"
  source_address_prefix        = "*"
  destination_address_prefixes = flatten([var.GLOBAL_VNET_SUBNETS.aks])
  network_security_group_name  = azurerm_network_security_group.sgMain.name
  resource_group_name          = azurerm_resource_group.rgMain.name
}

resource "azurerm_network_security_rule" "rule30010" {
  name                         = "${var.GLOBAL_RESOURCENAME_PREFIX}rule30010_inb"
  priority                     = 160
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "30010"
  source_address_prefix        = "*"
  destination_address_prefixes = flatten([var.GLOBAL_VNET_SUBNETS.aks])
  network_security_group_name  = azurerm_network_security_group.sgMain.name
  resource_group_name          = azurerm_resource_group.rgMain.name
}

resource "azurerm_network_security_rule" "rule30011" {
  name                         = "${var.GLOBAL_RESOURCENAME_PREFIX}rule30011_inb"
  priority                     = 165
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "30011"
  source_address_prefix        = "*"
  destination_address_prefixes = flatten([var.GLOBAL_VNET_SUBNETS.aks])
  network_security_group_name  = azurerm_network_security_group.sgMain.name
  resource_group_name          = azurerm_resource_group.rgMain.name
}

resource "azurerm_network_security_rule" "rule443" {
  name                         = "${var.GLOBAL_RESOURCENAME_PREFIX}rule443_inb"
  network_security_group_name  = azurerm_network_security_group.sgAks.name
  resource_group_name          = azurerm_resource_group.rgMain.name
  priority                     = 150
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefix        = "*"
  destination_address_prefixes = flatten([azurerm_subnet.subnetAks.address_prefixes])
}
