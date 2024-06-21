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
  description = "Confluent Cloud cluster API Key (also referred as Cloud API ID)"
  type        = string
}

variable "cluster_api_secret" {
  description = "Confluent Cloud cluster API Secret"
  type        = string
  sensitive   = true
}

variable "cluster_id" {
  description = "The ID the the Kafka cluster of the form lkc-"
  type        = string
}

variable "rest_endpoint" {
  description = "Kafka REST endpoint"
  type        = string
}

variable "check_create" {
  description = "The condition to create or not new topics"
  type        = bool
}

variable "check_modify" {
  description = "The condition to modify or not topics"
  type        = bool
}

variable "environment_id" {
  description = "The ID of the environment of the form env-"
  type        = string
}

variable "get_topics" {
  description = "A map of Kafka topic configurations"
  type = map(object({
    config : map(string),
    partitions_count : string
  }))
  default = {}
}

variable "create_topic" {
  description = "A map of Kafka topic configurations"
  type = map(object({
    config : map(string),
    partitions_count : string
  }))
  default = {}
}
