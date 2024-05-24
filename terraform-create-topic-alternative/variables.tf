# Variable for the above module
variable "topics" {
  description = "Topic variables for tfvars file"
  type = map(object({
    kafka_api_key              = string
    kafka_api_secret           = string
    varIdCluster               = string
    varTopic                   = string
    varPartitions              = string
    cleanupPolicy              = string
    retentionTime              = string
    maxMessageSize             = string
  }))
}
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