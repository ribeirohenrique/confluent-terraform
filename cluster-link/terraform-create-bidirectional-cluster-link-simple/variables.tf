variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "environment_id" {
  description = "Confluent Environment Id"
  type        = string
  sensitive   = true
}

variable "source_kafka_cluster_id" {
  description = "ID of the 'source' Kafka Cluster"
  type        = string
}

variable "destination_kafka_cluster_id" {
  description = "ID of the 'destination' Kafka Cluster"
  type        = string
}

variable "cluster_link_name" {
  description = "Name of the Cluster Link to create"
  type        = string
}

variable "source_service_account" {
  description = "Name of the Service account in Source Cluster"
  type        = string
}

variable "destination_service_account" {
  description = "Name of the Service account in Destination Cluster"
  type        = string
}