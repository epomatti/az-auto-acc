resource "azurerm_automation_account" "default" {
  name                = "aa-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  public_network_access_enabled = true
}

resource "azurerm_log_analytics_linked_service" "automation" {
  resource_group_name = var.resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  read_access_id      = azurerm_automation_account.default.id
}

# # https://stackoverflow.com/a/56210231/3231778
# resource "azurerm_log_analytics_solution" "example" {
#   solution_name         = "ContainerInsights"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   workspace_resource_id = azurerm_log_analytics_workspace.example.id
#   workspace_name        = azurerm_log_analytics_workspace.example.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }
# }

# resource "azurerm_log_analytics_saved_search" "example" {
#   name                       = "exampleSavedSearch"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

#   category     = "exampleCategory"
#   display_name = "exampleDisplayName"
#   query        = "exampleQuery"
# }

# resource "azurerm_automation_software_update_configuration" "example" {
#   name                  = "example"
#   automation_account_id = azurerm_automation_account.example.id
#   operating_system      = "Linux"

#   linux {
#     classification_included = "Security"
#     excluded_packages       = ["apt"]
#     included_packages       = ["vim"]
#     reboot                  = "IfRequired"
#   }

#   pre_task {
#     source = azurerm_automation_runbook.example.name
#     parameters = {
#       COMPUTER_NAME = "Foo"
#     }
#   }

#   duration = "PT2H2M2S"
# }

# resource "azurerm_monitor_diagnostic_setting" "default" {
#   name                       = "firewall-monitor"
#   target_resource_id         = azurerm_firewall.default.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category = "AZFWNetworkRule"
#   }

#   enabled_log {
#     category = "AZFWNatRule"
#   }

#   enabled_log {
#     category = "AZFWApplicationRule"
#   }

#   metric {
#     category = "AllMetrics"
#   }
# }
