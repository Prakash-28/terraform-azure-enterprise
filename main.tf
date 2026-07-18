module "network" {
  source                        = "./modules/network"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  vnet_name                     = var.vnet_name
  vnet_address_space            = var.vnet_address_space
  web_subnet_name               = var.web_subnet_name
  web_subnet_address_space      = var.web_subnet_address_space
  app_subnet_name               = var.app_subnet_name
  app_subnet_address_space      = var.app_subnet_address_space
  nsg_name                      = var.nsg_name
}

module "compute" {
  source = "./modules/compute"
  web_subnet_id = module.network.web_subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  public_ip_name      = var.public_ip_name
  vm_nic_name         = var.vm_nic_name
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
}