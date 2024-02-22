resource "azurerm_cosmosdb_account" "cdb" {
  name = "wthmnm${random_integer.ri.result}"

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  offer_type = "Standard"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
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

resource "azurerm_key_vault_secret" "cosmos_db" {
  name         = "cosmosDBAuthorizationKey"
  key_vault_id = azurerm_key_vault.kv.id
  value        = azurerm_cosmosdb_account.cdb.primary_key
}
