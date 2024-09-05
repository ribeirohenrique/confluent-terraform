variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "schema_api_key" {
  description = "Schema Registry API Key"
  type        = string
}

variable "schema_api_secret" {
  description = "Schema Registry API Secret"
  type        = string
  sensitive   = true
}

variable "cluster_id" {
  description = "Cluster Id"
  type        = string
  sensitive   = false
}

variable "environment_id" {
  description = "Environment Id"
  type        = string
  sensitive   = false
}

variable "business_metadata_name" {
  description = "Business Metadata name"
  type        = string
  sensitive   = false
}

variable "topic_name" {
  description = "Topic Name"
  type        = string
  sensitive   = false
}