terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.55.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}


//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

//Cria um tópico para gravar mensagens
resource "confluent_kafka_topic" "confluent_topic" {
  kafka_cluster {
    id = var.cluster_id
  }

  topic_name       = var.topic_name
  rest_endpoint    = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  partitions_count = 2
  config = {
    "cleanup.policy"                      = "delete"
    "delete.retention.ms"                 = "3600000"
    "max.compaction.lag.ms"               = "9223372036854775807"
    "max.message.bytes"                   = "2097164"
    "message.timestamp.difference.max.ms" = "9223372036854775807"
    "message.timestamp.type"              = "CreateTime"
    "min.compaction.lag.ms"               = "0"
    "min.insync.replicas"                 = "2"
    "retention.bytes"                     = "-1"
    "retention.ms"                        = "604800000"
    "segment.bytes"                       = "104857600"
    "segment.ms"                          = "604800000"
  }
  credentials {
    key    = var.service_account_cluster_key
    secret = var.service_account_cluster_secret
  }
}
