
resource "azurerm_public_ip" "publicIp1" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}publicIp1"
  location            = var.GLOBAL_LOCATION
  resource_group_name = azurerm_resource_group.rgMain.name
  allocation_method   = "Static"
  ip_version          = "IPv4"

}


resource "azurerm_network_interface" "nicMain" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}nicVm1"
  location            = azurerm_resource_group.rgMain.location
  resource_group_name = azurerm_resource_group.rgMain.name

  ip_configuration {
    name                          = "${var.GLOBAL_RESOURCENAME_PREFIX}nic_ip"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIp1.id
  }
}




resource "azurerm_virtual_machine" "vm1" {
  name                = "${var.GLOBAL_RESOURCENAME_PREFIX}vm1"
  location            = azurerm_resource_group.rgMain.location
  resource_group_name = azurerm_resource_group.rgMain.name

  network_interface_ids = [azurerm_network_interface.nicMain.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = "7.5"
    version   = "latest"
  }

  delete_os_disk_on_termination = true
  storage_os_disk {
    name              = "${var.GLOBAL_RESOURCENAME_PREFIX}osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm1"
    admin_username = var.vm1_host_user
    admin_password = var.vm1_host_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.vm1_host_user}/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAg3RTH8uWUOwIrBkwY/RRfFeqo6pqrgYNy/891gvNw4ZdoRtUAMPyUsIrjnrzCB4DdG4093U/mCKGKfb0dv4tKOUuV6k4wtdU6pzQ6E4dsZE0anqcuDKnp9/jwkEKWkxXCwIfQJmvW4odFqV0+Bnr4O1AfwuI/EQscXesJTRd+Nmafho/NXwS8L4qTFY7HTi0AQFeBKANP9oqRc4xkkCPYVhbtglnETQTKJDjp91D0PZqkWihDRtKsoV7jLp4ehBX+JryJBQdXAhnfDH+Hqc+Gt9iUR+pUei1KGNPPz0oVy50Qq5IfG3P3YnQ78IRifew4VSLVOEJQxnOda0xcRhSzmoHlhV2mE0zc2UXnaOds4953BnjJ31BvA/zVg2FmnBpnhvwZFSdgfXjSrdIf12fk7IaN9Y/TAtFaSj4gWfr6zfqXBv+IuQ6k3qlGbgjfZ71CESw9jKJu+TppjqPcVVw34nuadoFx4jlV2T572K+HbPhqf0u+yaYeWHL0u0V7tc= ${var.vm1_host_user}"
    }
  }
}


data "template_file" "userdataVm1" {
  template = file("./userdata.tpl")
  vars = {
    password = var.vm1_host_password
  }
}

output "vmIpPriv" {
  value = azurerm_network_interface.nicMain.private_ip_address
}

output "vmIpPub" {
  value = azurerm_public_ip.publicIp1.ip_address
}

resource "null_resource" "vmProvision" {
  connection {
    host     = azurerm_public_ip.publicIp1.ip_address
    type     = "ssh"
    password = var.vm1_host_password
    user     = var.vm1_host_user
  }

  provisioner "file" {
    content     = data.template_file.userdataVm1.rendered
    destination = "/home/${var.vm1_host_user}/userdata.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x /home/${var.vm1_host_user}/userdata.sh",
      "/home/${var.vm1_host_user}/userdata.sh",
      "rm -f /home/${var.vm1_host_user}/userdata.sh",
      "touch /home/${var.vm1_host_user}/userdata.ok"
    ]
  }

  depends_on = [
    azurerm_public_ip.publicIp1,
    azurerm_virtual_machine.vm1
  ]
}
