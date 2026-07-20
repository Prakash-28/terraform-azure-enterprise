# configure backend after storage account creation
# Note: 'key' is configured via pipeline -backend-config flag for environment-specific state files
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate1"
    storage_account_name = "tfstateab5f887b1"
    container_name       = "tfstate"
    # key is set dynamically by pipeline: dev.tfstate, test.tfstate, or prod.tfstate
    use_azuread_auth     = true
  }
}