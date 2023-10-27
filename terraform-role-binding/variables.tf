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

variable "organization_id" {
  description = "Confluent Organization Id"
  type        = string
  sensitive   = false
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

variable "topic_name" {
  description = "Confluent Topic Name"
  type        = string
  sensitive   = false
}

variable "rest_endpoint" {
  description = "Confluent REST endpoint"
  type        = string
  sensitive   = false
}

variable "consumer_group_id" {
  description = "Confluent Consumer Group ID"
  type        = string
  sensitive   = false
}