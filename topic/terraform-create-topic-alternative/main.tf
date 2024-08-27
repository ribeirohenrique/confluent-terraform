terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

resource "confluent_kafka_topic" "criar" {
  for_each = { for k, v in var.topics : k => v }
  kafka_cluster {
    id = each.value.varIdCluster
  }
  credentials {
    key    = each.value.kafka_api_key
    secret = each.value.kafka_api_secret
  }
  topic_name       = each.value.varTopic
  partitions_count = each.value.varPartitions
  rest_endpoint    = each.value.varRestEndpoint

  config = {
    "cleanup.policy"                      = each.value.cleanupPolicy
    "delete.retention.ms"                 = each.value.delete_retention_ms
    "max.compaction.lag.ms"               = each.value.max_compaction_lag_ms
    "max.message.bytes"                   = each.value.max_message_bytes
    "message.timestamp.after.max.ms"      = each.value.message_timestamp_after_max_ms
    "message.timestamp.before.max.ms"     = each.value.message_timestamp_before_max_ms
    "message.timestamp.difference.max.ms" = each.value.message_timestamp_difference_max_ms
    "message.timestamp.type"              = each.value.message_timestamp_type
    "min.compaction.lag.ms"               = each.value.min_compaction_lag_ms
    "min.insync.replicas"                 = each.value.min_insync_replicas
    "retention.bytes"                     = each.value.retention_bytes
    "retention.ms"                        = each.value.retentionTime
    "segment.bytes"                       = each.value.segment_bytes
    "segment.ms"                          = each.value.segment_ms
  }
}
