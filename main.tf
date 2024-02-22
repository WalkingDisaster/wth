terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.92.0"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}

data "azurerm_client_config" "current" {}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "wth"
  location = "westus3"
}

resource "azurerm_storage_account" "sa" {
  name = "wthmnm${random_integer.ri.result}"

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

resource "azapi_resource" "images_container" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01"
  name      = "images"
  parent_id = "${azurerm_storage_account.sa.id}/blobServices/default"
  body = jsonencode({
    properties = {
    }
  })
}

resource "azapi_resource" "export_container" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01"
  name      = "export"
  parent_id = "${azurerm_storage_account.sa.id}/blobServices/default"
  body = jsonencode({
    properties = {
    }
  })
}

resource "azurerm_eventgrid_topic" "eg" {
  name                = "wthmnm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_cognitive_account" "cv" {
  name                = "wthmnm${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "S1"
  kind     = "ComputerVision"
}

resource "azurerm_key_vault" "kv" {
  name                = "wthmnm${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled  = false
  enable_rbac_authorization = true

  depends_on = [azurerm_role_assignment.metokv]
}

resource "azurerm_key_vault_secret" "computer_vision" {
  name         = "computerVisionApiKey"
  key_vault_id = azurerm_key_vault.kv.id
  value        = azurerm_cognitive_account.cv.primary_access_key
}

resource "azurerm_key_vault_secret" "event_grid" {
  name         = "eventGridTopicKey"
  key_vault_id = azurerm_key_vault.kv.id
  value        = azurerm_eventgrid_topic.eg.primary_access_key
}

resource "azurerm_key_vault_secret" "storage" {
  name         = "blobStorageConnection"
  key_vault_id = azurerm_key_vault.kv.id
  value        = azurerm_storage_account.sa.primary_connection_string
}
