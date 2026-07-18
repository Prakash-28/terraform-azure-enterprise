# configure backend after storage account creation
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateab5f887b"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}