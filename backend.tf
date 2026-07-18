# configure backend after storage account creation
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate1"
    storage_account_name = "tfstateab5f887b1"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
    use_azuread_auth     = true
  }
}