variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "service_account_id" {
  description = "Service Account Id"
  type        = string
  sensitive   = false
}

variable "environment_name" {
  description = "Environment Name"
  type        = string
  sensitive   = false
}

variable "cluster_display_name" {
  description = "Cluster Name"
  type        = string
  sensitive   = false
}

variable "topics" {
  description = "List of topics to be created"
  type = map(object({
    topic_name          = string
    partition_count     = number
    cleanup_policy      = string
    delete_retention_ms = string
    max_message_bytes   = string
  }))
}
