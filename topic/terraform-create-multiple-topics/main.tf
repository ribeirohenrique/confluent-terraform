terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key       = var.cloud_api_key
  cloud_api_secret    = var.cloud_api_secret
}

resource "confluent_kafka_topic" "topics" {
  kafka_cluster {
    id = var.cluster_id
  }
  credentials {
    key    = var.cluster_api_key
    secret = var.cluster_api_secret
  }
  rest_endpoint    = var.kafka_rest_endpoint
  for_each         = var.topics
  topic_name       = each.key
  partitions_count = each.value.partitions_count
  config           = each.value.config

  lifecycle {
    prevent_destroy = false
  }
}