variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "kafka_api_key" {
  description = "Cluster API Key"
  type        = string
  sensitive   = true
}

variable "kafka_api_secret" {
  description = "Cluster API Secret"
  type        = string
  sensitive   = true
}

variable "environment_id" {
  description = "Confluent Environment Id"
  type        = string
  sensitive   = false
}

variable "cluster_id" {
  description = "Confluent Cluster Id"
  type        = string
  sensitive   = false
}

variable "service_account_id" {
  description = "Service Account Name"
  type        = string
  sensitive   = false
}

variable "role_name" {
  description = "Role Name"
  type        = string
  sensitive   = false
}

variable "topic_name" {
  description = "Topic Name"
  type        = string
  sensitive   = false
}

variable "rest_endpoint" {
  description = "REST endpoint"
  type        = string
  sensitive   = false
}