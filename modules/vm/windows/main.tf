locals {
  vm_affix = "win"
}

resource "azurerm_public_ip" "default" {
  name                = "pip-${var.workload}-${local.vm_affix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "default" {
  name                = "nic-${var.workload}-${local.vm_affix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  username = "sysadmin"
}

resource "azurerm_windows_virtual_machine" "default" {
  name                  = "vm-${var.workload}-${local.vm_affix}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = local.username
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.default.id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${var.workload}-${local.vm_affix}"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  tags = {
    Environment = "Production"
    OS          = "Windows"
  }
}

resource "azurerm_virtual_machine_extension" "azure_monitor_windows_agent" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.default.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.21"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

