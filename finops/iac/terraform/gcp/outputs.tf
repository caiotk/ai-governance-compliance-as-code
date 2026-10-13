output "budget_name" {
  value = google_billing_budget.workload.name
}

output "budget_pubsub_topic" {
  value = google_pubsub_topic.budget.id
}
