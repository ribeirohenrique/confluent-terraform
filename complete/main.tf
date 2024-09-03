terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_environment" "environment" {
  display_name = var.environment_display_name

  stream_governance {
    package = var.environment_stream_governance_type
  }

  lifecycle {
    prevent_destroy = false
  }
}

data "confluent_schema_registry_cluster" "schema_registry" {
  environment {
    id = confluent_environment.environment.id
  }
  depends_on = [confluent_kafka_cluster.cluster]
}

resource "confluent_kafka_cluster" "cluster" {
  display_name = var.cluster_display_name
  availability = var.cluster_availability
  cloud        = var.cluster_cloud_provider
  region       = var.cluster_cloud_region

  dedicated {
    cku = var.cluster_num_ckus
  }

  environment {
    id = confluent_environment.environment.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_network" "private_link" {
  display_name     = "Private Link Network"
  cloud            = confluent_kafka_cluster.cluster.cloud
  region           = confluent_kafka_cluster.cluster.region
  connection_types = ["PRIVATELINK"]
  zones            = var.network_zones
  environment {
    id = confluent_environment.environment.id
  }
}

resource "confluent_service_account" "service_account" {
  display_name = var.service_account_name
  description  = "Service account to interact with ${confluent_kafka_cluster.cluster.id} cluster"
}

resource "confluent_api_key" "service_account_kafka_api_key" {
  display_name = confluent_service_account.service_account.display_name
  description  = "Kafka API Key that is owned by ${confluent_service_account.service_account.id} service account"
  owner {
    id          = confluent_service_account.service_account.id
    api_version = confluent_service_account.service_account.api_version
    kind        = confluent_service_account.service_account.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.cluster.id
    api_version = confluent_kafka_cluster.cluster.api_version
    kind        = confluent_kafka_cluster.cluster.kind

    environment {
      id = confluent_environment.environment.id
    }
  }
}

resource "confluent_role_binding" "app_service_account_kafka_cluster" {
  principal   = "User:${confluent_service_account.service_account.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.cluster.rbac_crn

  depends_on = [confluent_service_account.service_account]
}

resource "confluent_role_binding" "app_service_account_kafka_environment" {
  principal   = "User:${confluent_service_account.service_account.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.environment.resource_name
  depends_on = [confluent_service_account.service_account]
}

resource "confluent_role_binding" "app_service_account_kafka_topic" {
  principal   = "User:${confluent_service_account.service_account.id}"
  role_name   = var.service_account_role_name
  crn_pattern = "${confluent_kafka_cluster.cluster.rbac_crn}/kafka=${confluent_kafka_cluster.cluster.id}/topic=${confluent_kafka_topic.topic.topic_name}"
}

resource "confluent_kafka_topic" "topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.cluster.id
  }
  topic_name       = var.topic_name
  rest_endpoint    = confluent_kafka_cluster.cluster.rest_endpoint
  partitions_count = var.topic_partitions

  config = {
    "cleanup.policy"      = "delete"
    "delete.retention.ms" = "3600000"
    "max.message.bytes"   = "5000000"
    "retention.bytes"     = "104857600"
    "retention.ms"        = "86400000"
    "segment.bytes"       = "52428800"
    "segment.ms"          = "86400000"
  }
  credentials {
    key    = confluent_api_key.service_account_kafka_api_key.id
    secret = confluent_api_key.service_account_kafka_api_key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_role_binding.app_service_account_kafka_cluster]
}

resource "confluent_tag" "tagging" {
  name          = var.tag_name
  description   = "ENVIRONMENT - ${var.tag_name} - TAG"
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint

  lifecycle {
    prevent_destroy = false
  }
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry.id
  }
  credentials {
    key    = confluent_api_key.schema_registry_api_key.id
    secret = confluent_api_key.schema_registry_api_key.secret
  }
  depends_on = [confluent_api_key.schema_registry_api_key]
}

resource "confluent_tag_binding" "topic_tagging" {
  tag_name      = var.tag_name
  entity_name   = "${data.confluent_schema_registry_cluster.schema_registry.id}:${confluent_kafka_cluster.cluster.id}:${confluent_kafka_topic.topic.topic_name}"
  entity_type   = "kafka_topic"
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry.id
  }
  credentials {
    key    = confluent_api_key.schema_registry_api_key.id
    secret = confluent_api_key.schema_registry_api_key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_api_key.schema_registry_api_key]
}

resource "confluent_api_key" "schema_registry_api_key" {
  display_name = "schema_${confluent_service_account.service_account.display_name}"
  description  = "Schema Registry API Key that is owned by ${confluent_service_account.service_account.id} service account"
  owner {
    id          = confluent_service_account.service_account.id
    api_version = confluent_service_account.service_account.api_version
    kind        = confluent_service_account.service_account.kind
  }
  managed_resource {
    id          = data.confluent_schema_registry_cluster.schema_registry.id
    api_version = data.confluent_schema_registry_cluster.schema_registry.api_version
    kind        = data.confluent_schema_registry_cluster.schema_registry.kind

    environment {
      id = confluent_environment.environment.id
    }
  }
  disable_wait_for_ready = true
}

resource "confluent_schema" "schemas" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry.rest_endpoint
  subject_name  = "${confluent_kafka_topic.topic.topic_name}-value"
  format        = "AVRO"
  schema        = file("${var.schema_path}")
  credentials {
    key    = confluent_api_key.schema_registry_api_key.id
    secret = confluent_api_key.schema_registry_api_key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}