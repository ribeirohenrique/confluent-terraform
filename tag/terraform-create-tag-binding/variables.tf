variable "cluster_id" {
  description = "Confluent Cluster Id"
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

variable "topic_tags" {
  description = "Topic Tag"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
}

variable "connector_tags" {
  description = "Connector Tag"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
}

variable "environment_tags" {
  description = "Environment Tag"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
}

variable "cluster_link_tags" {
  description = "Cluster Link Tags"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
}

variable "schema_tags" {
  description = "Schema Tags"
  type = map(object({
    tag_name : string
    entity_type : string
  }))
  default = {}
}