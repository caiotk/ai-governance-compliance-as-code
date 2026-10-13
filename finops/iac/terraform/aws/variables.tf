variable "region" {
  type    = string
  default = "us-east-1"
}

variable "workload_id" {
  type = string
}

variable "monthly_budget_usd" {
  type = number
}

variable "budget_service_filter" {
  description = "Cost Explorer 'Service' values the budget covers. The Price List API names the offer 'Amazon Bedrock'; third-party foundation-model usage may bill under '<Model> (Amazon Bedrock Edition)' service names — UNVERIFIED, so prefer tag-based allocation (cost_allocation_tag) and treat this filter as a floor."
  type        = list(string)
  default     = ["Amazon Bedrock"]
}

variable "cost_allocation_tag" {
  description = "Cost-allocation tag key carried by application inference profiles (activated in Billing → Cost allocation tags)."
  type        = string
  default     = "aigov-workload"
}

variable "alert_thresholds_percent" {
  type    = list(number)
  default = [50, 80, 100]
}

variable "subscriber_emails" {
  type = list(string)
}

variable "foundation_model_arn" {
  description = "ARN of the foundation model or system-defined inference profile the application inference profile tracks (copy_from)."
  type        = string
}

variable "input_tokens_per_hour_alert" {
  type = number
}

variable "output_tokens_per_hour_alert" {
  type = number
}

variable "model_id_dimension" {
  description = "ModelId dimension value for the CloudWatch alarms (bare model id or inference profile id)."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
