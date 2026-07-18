variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network to create."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space of the virtual network."
  type        = list(string)
}

variable "web_subnet_name" {
  description = "The name of the web subnet to create."
  type        = string
}

variable "web_subnet_address_space" {
  description = "The address space of the web subnet."
  type        = list(string)
}

variable "app_subnet_name" {
  description = "The name of the app subnet to create."
  type        = string
}

variable "app_subnet_address_space" {
  description = "The address space of the app subnet."
  type        = list(string)
}

variable "nsg_name" {
  description = "The name of the network security group to create."
  type        = string
}
