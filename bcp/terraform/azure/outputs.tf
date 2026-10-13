output "primary_deployment" {
  value = azurerm_cognitive_deployment.primary.name
}

output "secondary_deployment" {
  value = azurerm_cognitive_deployment.secondary.name
}
