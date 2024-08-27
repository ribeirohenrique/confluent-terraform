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

# This repo is for the creation of Clusterlink - Destination Initiated
# Variable for the above module
variable "cluster_links" {
  description = "Cluster link variables for tfvars file"
  type = map(object({
    source_kafka_api_key         = string
    source_kafka_api_secret      = string
    destination_kafka_api_key    = string
    destination_kafka_api_secret = string
    environment_id               = string
    varLinkName                  = string
    source_kafka_cluster_id      = string
    destination_kafka_cluster_id = string
    rest_endpoint                = string
    bootstrap_endpoint           = string
    link_mode                    = string
  }))
}

variable "source_topics" {
  description = "Cluster link variables for tfvars file"
  type = map(object({
    topic_name = string
  }))
}