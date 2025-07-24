terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"

    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_environment" "environment" {
  display_name = var.environment_name
}

data "confluent_service_account" "terraform_sa" {
  id = var.service_account_id
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "dedicated" {
  display_name = var.cluster_display_name
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "us-central1"
  dedicated {
    cku = 1
  }

  environment {
    id = data.confluent_environment.environment.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_role_binding" "role_cluster_admin" {
  principal   = "User:${var.service_account_id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.dedicated.rbac_crn
}

resource "confluent_api_key" "cluster_api_key" {
  display_name = "user_${var.service_account_id}"
  description  = "Kafka API Key that is owned by ${var.service_account_id} service account"
  owner {
    id          = data.confluent_service_account.terraform_sa.id
    api_version = data.confluent_service_account.terraform_sa.api_version
    kind        = data.confluent_service_account.terraform_sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.dedicated.id
    api_version = confluent_kafka_cluster.dedicated.api_version
    kind        = confluent_kafka_cluster.dedicated.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.role_cluster_admin,
    confluent_kafka_cluster.dedicated
  ]
}

resource "confluent_kafka_topic" "topics" {
  for_each = { for k, v in var.topics : k => v }
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  topic_name       = each.value.topic_name
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  partitions_count = each.value.partition_count
  config = {
    "cleanup.policy"      = each.value.cleanup_policy
    "delete.retention.ms" = each.value.delete_retention_ms
    "max.message.bytes"   = each.value.max_message_bytes
    "retention.bytes"     = "104857600"
    "retention.ms"        = "86400000"
    "segment.bytes"       = "52428800"
    "segment.ms"          = "86400000"
  }
  credentials {
    key    = confluent_api_key.cluster_api_key.id
    secret = confluent_api_key.cluster_api_key.secret
  }
}
