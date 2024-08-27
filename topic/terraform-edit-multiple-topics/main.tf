terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.cloud_api_key
  cloud_api_secret = var.cloud_api_secret

  kafka_api_key    = var.cluster_api_key
  kafka_api_secret = var.cluster_api_secret

  kafka_rest_endpoint = var.rest_endpoint
  kafka_id            = var.cluster_id
}

//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

data "confluent_kafka_topic" "get_topics" {
  for_each = var.check_modify ? var.get_topics : {}
  kafka_cluster {
    id = data.confluent_kafka_cluster.confluent_cluster.id
  }
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  topic_name    = each.key
}

variable "modify_params" {
  type = map(string)
  default = {
    "max.message.bytes" = "7777776"
  }
}

locals {
  topics_to_create = var.check_create ? var.create_topic : {}
}

resource "confluent_kafka_topic" "create_topic" {
  
  for_each         = local.topics_to_create
  topic_name       = each.key
  partitions_count = "2"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      topic_name,
      partitions_count,
      config

    ]
  }
}

resource "confluent_kafka_topic" "modify_topic" {
  for_each         = var.check_modify ? var.get_topics : {}
  topic_name       = each.key
  partitions_count = "2"
  config           = merge(data.confluent_kafka_topic.get_topics[each.key].config, var.modify_params)

  lifecycle {
    prevent_destroy = true
  }
}
