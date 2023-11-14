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

# https://stackoverflow.com/a/56210231/3231778
resource "azurerm_log_analytics_solution" "automation" {
  solution_name         = "Updates"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = var.log_analytics_workspace_id
  workspace_name        = var.log_analytics_workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

# resource "azurerm_automation_runbook" "python" {
#   name                    = "Get-AzureVMTutorial"
#   location                = var.location
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.default.name

#   log_verbose  = "true"
#   log_progress = "true"
#   description  = "This is a example runbook for terraform acceptance example"
#   runbook_type = "Python3"

#   content = <<CONTENT
# # Some example content
# # for Terraform acceptance example
# CONTENT
# }

resource "azurerm_automation_software_update_configuration" "linux" {
  name                  = "LinuxUpdates"
  automation_account_id = azurerm_automation_account.default.id
  duration              = "PT2H"

  linux {
    classification_included = "Security"
    excluded_packages       = ["apt"]
    included_packages       = ["vim"]
    reboot                  = "IfRequired"
  }

  # pre_task {
  #   source = azurerm_automation_runbook.python.name
  #   parameters = {
  #     COMPUTER_NAME = "Foo"
  #   }
  # }

  schedule {
    is_enabled  = true
    description = "Terraform schedule"
    frequency   = "Hour"
    interval    = 1
  }

}

# resource "azurerm_log_analytics_saved_search" "example" {
#   name                       = "exampleSavedSearch"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

#   category     = "exampleCategory"
#   display_name = "exampleDisplayName"
#   query        = "exampleQuery"
# }
