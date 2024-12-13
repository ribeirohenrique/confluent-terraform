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

variable "topics" {
  description = "A map of Kafka topic configurations"
  type = map(object({
    topic_description = string
    topic_owner = string
    topic_owner_email = string
  }))
  default = {}
}

variable "schemas" {
  description = "A map of Kafka schemas configurations"
  type = map(object({
    schema_description : string
  }))
  default = {}
}

variable "clusters" {
  description = "A map of Kafka clusters configurations"
  type = map(object({
    cluster_description : string
  }))
  default = {}
}

variable "environments" {
  description = "A map of Kafka environments configurations"
  type = map(object({
    environment_description : string
  }))
  default = {}
}

variable "connectors" {
  description = "A map of Kafka connectors configurations"
  type = map(object({
    connector_description : string
  }))
  default = {}
}

variable "cluster_link" {
  description = "A map of Kafka cluster link configurations"
  type = map(object({
    clusterlink_description : string
  }))
  default = {}
}