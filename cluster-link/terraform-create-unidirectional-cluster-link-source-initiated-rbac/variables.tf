variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}


#### SOURCE
variable "source_environment_id" {
  description = "Confluent Source Environment Id"
  type        = string
  sensitive   = true
}

variable "source_kafka_cluster_id" {
  description = "ID of the 'source' Kafka Cluster"
  type        = string
}

variable "source_service_account" {
  description = "Name of the Service account in Source Cluster"
  type        = string
}

variable "source_topic_name" {
  description = "Name of the Topic on the 'source' Kafka Cluster to create a Mirror Topic for"
  type        = string
}


#### DESTINATION
variable "destination_environment_id" {
  description = "Confluent Destination Environment Id"
  type        = string
  sensitive   = true
}

variable "destination_kafka_cluster_id" {
  description = "ID of the 'destination' Kafka Cluster"
  type        = string
}

variable "destination_service_account" {
  description = "Name of the Service account in Destination Cluster"
  type        = string
}

### MISC
variable "cluster_link_name" {
  description = "Name of the Cluster Link to create"
  type        = string
}

variable "create_mirror_topic" {
  description = "Define se o recurso confluent_kafka_mirror_topic deve ser criado"
  type        = bool
  default     = false
}