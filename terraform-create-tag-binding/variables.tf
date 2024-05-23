variable "cluster_id" {
  description = "Confluent Cluster Id"
  type        = string
  sensitive   = false
}

variable "topic_name" {
  description = "Topic Name"
  type        = string
  sensitive   = false
}

variable "schema_registry_id" {
  description = "Confluent Schema Registry Id"
  type        = string
  sensitive   = false
}

variable "schema_registry_rest_endpoint" {
  description = "Confluent Schema Registry REST Endpoint"
  type        = string
  sensitive   = false
}

variable "schema_registry_api_key" {
  description = "Confluent Schema Registry API Key"
  type        = string
  sensitive   = true
}

variable "schema_registry_api_secret" {
  description = "Confluent Schema Registry API Secret"
  type        = string
  sensitive   = true
}
