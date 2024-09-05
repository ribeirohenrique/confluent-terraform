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

data "confluent_business_metadata" "recovery_business_metadata" {

    schema_registry_cluster {
      id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
    }
    rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
    credentials {
      key    = var.schema_api_key
      secret = var.schema_api_secret
    }
    name = var.business_metadata_name
}

resource "confluent_business_metadata_binding" "business_metadata_bind" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  business_metadata_name = data.confluent_business_metadata.recovery_business_metadata.name
  entity_name = "${data.confluent_schema_registry_cluster.schema_registry_cluster.id}:${data.confluent_kafka_cluster.cluster.id}:${var.topic_name}"
  entity_type = "kafka_topic"
  attributes = {
    "team" = "teamName"
    "email" = "team@company.com"
  }

  lifecycle {
    prevent_destroy = false
  }
}