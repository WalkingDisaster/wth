
resource "azurerm_service_plan" "asp" {
  name                = "wthmnm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_storage_account" "appsa" {
  name                = "wthmnmapp${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = "Allow"
  }
}

resource "azurerm_linux_function_app" "app" {
  name                = "wthmnmapp${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.appsa.name
  storage_account_access_key = azurerm_storage_account.appsa.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version              = "6.0"
      use_dotnet_isolated_runtime = false
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "eventssa" {
  name                = "wthmnmevents${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"

  network_rules {
    bypass         = ["AzureServices", "Logging", "Metrics"]
    default_action = "Allow"
  }
}

resource "azurerm_linux_function_app" "events" {
  name                = "wthmnmevents${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.eventssa.name
  storage_account_access_key = azurerm_storage_account.eventssa.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
