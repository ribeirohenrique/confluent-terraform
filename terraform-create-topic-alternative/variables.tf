# Variable for the above module
variable "topics" {
  description = "Topic variables for tfvars file"
  type = map(object({
    kafka_api_key                       = string
    kafka_api_secret                    = string
    varIdCluster                        = string
    varTopic                            = string
    varPartitions                       = string
    varRestEndpoint                     = string
    cleanupPolicy                       = string
    retentionTime                       = string
    delete_retention_ms                 = string
    max_compaction_lag_ms               = string
    max_message_bytes                   = string
    message_timestamp_after_max_ms      = string
    message_timestamp_before_max_ms     = string
    message_timestamp_difference_max_ms = string
    message_timestamp_type              = string
    min_compaction_lag_ms               = string
    min_insync_replicas                 = string
    retention_bytes                     = string
    segment_bytes                       = string
    segment_ms                          = string
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
