terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.confluent_cloud_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}


# data "confluent_kafka_topic" "main" {
#   for_each = { for k, v in var.topics : k => v }
#   topic_name    = each.key
#   rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
# }

# resource "confluent_kafka_topic" "main" {
#   for_each = { for k, v in var.topics : k => v }
#   topic_name       = each.value.varTopic
#   partitions_count = each.value.varPartitions

#   config = merge(data.confluent_kafka_topic.main.config[cleanup.policy], each.value.varTopicConfig)

#   /* Inutilizado até encontrarmos contorno
#   lifecycle {
#     prevent_destroy = true
#   }*/
# }

data "confluent_kafka_topic" "confluent_topics" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.confluent_cluster.id
  }

  topic_name    = var.topic_name
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint

  credentials {
    key    = var.service_account_cluster_key
    secret = var.service_account_cluster_secret
  }
}

data "confluent_kafka_topic" "main" {
  for_each = { for k, v in var.topics : k => v }
  topic_name    = each.value.varTopic
  rest_endpoint = each.value.varRestEndPoint
}