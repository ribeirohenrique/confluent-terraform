terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.7.0"
    }
  }
}

provider "confluent" {
  cloud_api_key                 = var.cloud_api_key
  cloud_api_secret              = var.cloud_api_secret
  schema_registry_id            = var.schema_registry_id            # optionally use SCHEMA_REGISTRY_ID env var
  schema_registry_rest_endpoint = var.schema_registry_rest_endpoint # optionally use SCHEMA_REGISTRY_REST_ENDPOINT env var
  schema_registry_api_key       = var.schema_registry_api_key       # optionally use SCHEMA_REGISTRY_API_KEY env var
  schema_registry_api_secret    = var.schema_registry_api_secret    # optionally use SCHEMA_REGISTRY_API_SECRET env var
}

data "confluent_kafka_cluster" "cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

data "confluent_schema_registry_cluster" "schema_registry_cluster" {
  environment {
    id = var.environment_id
  }
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

resource "confluent_tag_binding" "topic_tagging" {
  for_each    = var.tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${var.cluster_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_catalog_entity_attributes" "topics" {
  for_each = var.topics_info
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_registry_api_key
    secret = var.schema_registry_api_secret
  }

  entity_name = "${data.confluent_kafka_cluster.cluster.id}:${each.key}"
  entity_type = "kafka_topic"
  attributes = {
    "owner"       = each.value.topic_owner
    "description" = each.value.topic_description
    "ownerEmail"  = each.value.topic_owner_email
  }

  lifecycle {
    prevent_destroy = false
  }
}