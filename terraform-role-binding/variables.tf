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

variable "confluent_crn" {
  description = "Confluent CRN"
  type        = string
  sensitive   = false
}

variable "confluent_crn_rb" {
  description = "Confluent CRN Role Binding"
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
