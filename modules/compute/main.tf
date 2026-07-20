# compute module

# Creation of Public IP for the VM
resource "azurerm_public_ip" "vm_pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Creation of Network Interface for the VM
resource "azurerm_network_interface" "vm_nic" {
  name                = var.vm_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
    }
}

# Creation of Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
    name           = var.vm_name
    computer_name  = substr(replace(var.vm_name, "_", "-"), 0, 64)
    resource_group_name = var.resource_group_name
    location       = var.location
    size           = var.vm_size
    admin_username = var.admin_username
    network_interface_ids = [azurerm_network_interface.vm_nic.id]
    admin_ssh_key {
        username   = var.admin_username
        public_key = var.ssh_public_key
    }
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku        = "22_04-lts-gen2"
        version    = "latest"
    }
}
