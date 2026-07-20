variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP to create."
  type        = string
}

variable "vm_nic_name" {
  description = "The name of the network interface to create."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine to create."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine to create."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

variable "web_subnet_id" {
description = "Subnet ID for VM NIC"
type = string
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
}