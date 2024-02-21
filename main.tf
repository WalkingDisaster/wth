terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.92.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "wth"
  location = "eastus"
}

resource "azurerm_cosmosdb_account" "cdb" {
  name = "wthmnm${random_integer.ri.result}"

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  offer_type = "Standard"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "eastus"
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name = "LicensePlates"

  account_name        = azurerm_cosmosdb_account.cdb.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_cosmosdb_sql_container" "processed_container" {
  name = "Processed"

  account_name        = azurerm_cosmosdb_account.cdb.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  resource_group_name = azurerm_resource_group.rg.name

  partition_key_path = "/licensePlateText"
}

resource "azurerm_cosmosdb_sql_container" "needs_review_container" {
  name = "NeedsManualReview"

  account_name        = azurerm_cosmosdb_account.cdb.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  resource_group_name = azurerm_resource_group.rg.name

  partition_key_path = "/fileName"
}

resource "azurerm_storage_account" "sa" {
  name = "wthmnm${random_integer.ri.result}"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "images_container" {
  name                 = "images"
  storage_account_name = azurerm_storage_account.sa.name
}

resource "azurerm_storage_container" "export_container" {
  name                 = "export"
  storage_account_name = azurerm_storage_account.sa.name
}

resource "azurerm_user_assigned_identity" "id" {
  name = "wthmnm${random_integer.ri.result}"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_service_plan" "asp" {
  name                = "wthmnm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "Y1"
}

resource "azurerm_linux_function_app" "app" {
  name                = "wthmnmapp${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
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

resource "azurerm_linux_function_app" "events" {
  name                = "wthmnmevents${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
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

  soft_delete_retention_days = 0
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "apptokv" {
  scope              = azurerm_key_vault.kv.id
  role_definition_id = "4633458b-17de-408a-b874-0445c86b69e6" # Key Vault Secrets User
  principal_id       = azurerm_linux_function_app.app.identity.object_id
}

resource "azurerm_role_assignment" "apptokv" {
  scope              = azurerm_key_vault.kv.id
  role_definition_id = "4633458b-17de-408a-b874-0445c86b69e6" # Key Vault Secrets User
  principal_id       = azurerm_linux_function_app.events.identity.object_id
}
