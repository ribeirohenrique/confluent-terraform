variable "cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "cluster_api_key" {
  description = "Confluent cluster API Key"
  type        = string
}

variable "cluster_api_secret" {
  description = "Confluent cluster API Secret"
  type        = string
  sensitive   = true
}

variable "kafka_rest_endpoint" {
  description = "The REST Endpoint of the Kafka cluster"
  type        = string
}

variable "cluster_id" {
  description = "The ID the the Kafka cluster of the form 'lkc-'"
  type        = string
}

variable "topics" {
  description = "A map of Kafka topic configurations"
  type = map(object({
    config : map(string),
    partitions_count : string
  }))
  default = {}
}

variable "tags" {
  description = "Tag Name"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
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

variable "topics_info" {
  description = "A map of Kafka topic configurations"
  type = map(object({
    topic_description = string
    topic_owner = string
    topic_owner_email = string
  }))
  default = {}
}

variable "environment_id" {
  description = "Environment Id"
  type        = string
  sensitive   = false
}