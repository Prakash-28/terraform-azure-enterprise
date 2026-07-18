# Terraform Azure Enterprise

Terraform configuration to provision a small Azure enterprise baseline with reusable modules.

## What this deploys

- Resource Group
- Virtual Network
- Web subnet and app subnet
- Network Security Group + HTTP inbound rule on web subnet
- Public IP
- Network Interface in web subnet
- Linux Virtual Machine

## Project structure

```text
.
├── backend.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
├── versions.tf
├── environments/
│   ├── dev.tfvars
│   ├── test.tfvars
│   └── prod.tfvars
└── modules/
		├── network/
		│   ├── main.tf
		│   ├── variables.tf
		│   └── outputs.tf
		├── compute/
		│   ├── main.tf
		│   ├── variables.tf
		│   └── outputs.tf
		├── monitoring/
		└── security/
```

## How it works

1. Root module (`main.tf`) calls `network` module first.
2. `network` module creates RG, VNet, subnets, NSG, and NSG association.
3. `network` module exports `web_subnet_id` via module output.
4. Root module passes `web_subnet_id` into `compute` module.
5. `compute` module creates Public IP, NIC in the web subnet, and Linux VM.

This module-to-module handoff avoids cross-module references inside child modules.

## Prerequisites

- Terraform >= 1.7.0
- Azure subscription
- Azure CLI authenticated (`az login`) or equivalent environment credentials
- SSH public key file at `~/.ssh/id_rsa.pub` (used by the VM resource)

## Provider and version

- Provider: `hashicorp/azurerm` `~> 4.0`
- Terraform version: `>= 1.7.0`

## Configuration

Set values in `terraform.tfvars` (or environment-specific tfvars under `environments/`).

Current root variables:

- `subscription_id`
- `location`
- `resource_group_name`
- `vnet_name`
- `vnet_address_space`
- `web_subnet_name`
- `web_subnet_address_space`
- `app_subnet_name`
- `app_subnet_address_space`
- `nsg_name`
- `public_ip_name`
- `vm_nic_name`
- `vm_name`
- `vm_size`
- `admin_username`

## Commands

From repository root:

```bash
terraform init -reconfigure
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Use environment tfvars example:

```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

## Backend

`backend.tf` is currently a placeholder. Add your remote state backend (recommended for teams), for example Azure Storage backend.

## Notes

- The root `outputs.tf` is currently empty; add outputs you want to expose from the root module (for example VM public IP, NIC ID, or subnet IDs).
- In the compute module, `azurerm_linux_virtual_machine` reads SSH key from `~/.ssh/id_rsa.pub`; ensure the key exists on the machine running Terraform.

## Troubleshooting

- `Unexpected attribute` in editor, but `terraform validate` passes:
	- run `terraform init -reconfigure`
	- reload VS Code window to refresh Terraform language server cache
- `Reference to undeclared module` in child module:
	- pass required values through module inputs and outputs
	- do not reference sibling/root modules directly from inside a child module

## Future enhancements

- Add root outputs for important resources
- Implement remote backend in `backend.tf`
- Add environment-specific tfvars values for dev/test/prod
- Expand `monitoring` and `security` modules and wire them from root
