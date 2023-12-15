# Variable for the above module
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

variable "pubsub_connectors" {
  description = "Topic variables for tfvars file"
  type = map(object({
    confluent_kafka_cluster_id = string
    confluent_environment_id   = string
    service_account_id         = string
    keyfile                    = any
    connector_name             = string
    topic_name                 = string
    gcp_project_id             = string
    gcp_topic_id               = string
    gcp_subscription_id        = string
    task_max                   = string
  }))

}
