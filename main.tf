terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

locals {
  workload = "todoapp"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "vm_linux" {
  source              = "./modules/vm/linux"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.subnet_id
  size                = var.linux_vm_size
}

module "vm_windows" {
  source              = "./modules/vm/windows"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = module.vnet.subnet_id
  size                = var.windows_vm_size
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.workload}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "automation" {
  count                        = var.create_automation_resources == true ? 1 : 0
  source                       = "./modules/automation"
  workload                     = local.workload
  resource_group_name          = azurerm_resource_group.default.name
  resource_group_id            = azurerm_resource_group.default.id
  location                     = azurerm_resource_group.default.location
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.default.id
  log_analytics_workspace_name = azurerm_log_analytics_workspace.default.name
}

module "storage" {
  source              = "./modules/storage"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}
