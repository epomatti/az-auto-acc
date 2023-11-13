resource "azurerm_automation_account" "example" {
  name                = "aa-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  public_network_access_enabled = true
}
