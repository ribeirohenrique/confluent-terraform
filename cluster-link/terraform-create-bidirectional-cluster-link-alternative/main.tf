terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_cluster_link" "link_clusters" {
  for_each        = { for k, v in var.cluster_links : k => v }
  link_name       = each.value.varLinkName
  link_mode       = each.value.link_mode
  connection_mode = "OUTBOUND"

  config = {
    "acl.sync.enable" : "true",
    "acl.sync.ms" : "5000",
    "auto.create.mirror.topics.enable" : "true",
    "topic.config.sync.ms" : "5000"
    "consumer.offset.sync.enable" : "true"
  }

  local_kafka_cluster {
    id            = each.value.source_kafka_cluster_id
    rest_endpoint = each.value.source_rest_endpoint
    credentials {
      key    = each.value.source_kafka_api_key
      secret = each.value.source_kafka_api_secret
    }
  }

  remote_kafka_cluster {
    id                 = each.value.destination_kafka_cluster_id
    bootstrap_endpoint = each.value.destination_bootstrap_endpoint
    credentials {
      key    = each.value.destination_kafka_api_key
      secret = each.value.destination_kafka_api_secret
    }
  }
}

resource "confluent_kafka_mirror_topic" "mirror_topic" {
  for_each = { for k, v in var.topics : k => v }
  source_kafka_topic {
    topic_name = each.value.topic_name
  }
  cluster_link {
    link_name = each.value.link_name
  }
  kafka_cluster {
    id            = each.value.cluster_id
    rest_endpoint = each.value.rest_endpoint
    credentials {
      key    = each.value.kafka_api_key
      secret = each.value.kafka_api_secret
    }
  }
  lifecycle {
    prevent_destroy = false
  }

  depends_on = [confluent_cluster_link.link_clusters]
}