terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

resource "confluent_kafka_topic" "criar" {
  for_each = { for k, v in var.topics : k => v }
  kafka_cluster {
    id = each.value.varIdCluster
  }
  topic_name       = each.value.varTopic
  partitions_count = each.value.varPartitions
  rest_endpoint    = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint

  config = {
    "cleanup.policy"    = each.value.cleanupPolicy
    "retention.ms"      = each.value.retentionTime
    "max.message.bytes" = each.value.maxMessageSize
  }

  lifecycle {
    prevent_destroy = true
  }
}