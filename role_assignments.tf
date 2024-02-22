# resource "azurerm_role_assignment" "metosab" {
#   scope                = azurerm_resource_group.rg.id
#   role_definition_name = "Storage Blob Data Owner" # "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# resource "azurerm_role_assignment" "metosaq" {
#   scope                = azurerm_resource_group.rg.id
#   role_definition_name = "Storage Queue Data Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

resource "azurerm_role_assignment" "metokv" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Key Vault Administrator" # "00482a5a-887f-4fb3-b363-3b7fe8e74483"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "apptokv" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User" # "4633458b-17de-408a-b874-0445c86b69e6"
  principal_id         = azurerm_linux_function_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "eventstokv" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User" # "4633458b-17de-408a-b874-0445c86b69e6"
  principal_id         = azurerm_linux_function_app.events.identity[0].principal_id
}
