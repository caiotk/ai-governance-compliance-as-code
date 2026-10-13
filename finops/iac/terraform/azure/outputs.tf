output "budget_id" {
  value = azurerm_consumption_budget_resource_group.workload.id
}

output "token_alert_id" {
  value = azurerm_monitor_metric_alert.tokens_per_hour.id
}
