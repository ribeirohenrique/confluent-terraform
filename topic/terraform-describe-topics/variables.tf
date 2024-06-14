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

variable "service_account_cluster_key" {
  description = "Service Account Cluster key"
  type        = string
  sensitive   = true
}

variable "service_account_cluster_secret" {
  description = "Service Account Cluster secret"
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

variable "topic_name" {
  description = "Confluent Cluster topic"
  type        = string
  sensitive   = false
}
variable "topics" {
  description = "Topic variables for tfvars file"
  type = map(object({
    confluent_cloud_api_key    = optional(string)
    confluent_cloud_api_secret = optional(string)
    kafka_api_key              = optional(string)
    kafka_api_secret           = optional(string)
    varIdCluster               = optional(string)
    varTopic                   = optional(string)
    varTopicConfig             = map(string)
    varPartitions              = optional(string)
    varRestEndPoint            = optional(string)
    cleanupPolicy              = optional(string)
    retentionTime              = optional(string)
  }))
}