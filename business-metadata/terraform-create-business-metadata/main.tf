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

resource "confluent_business_metadata" "business_metadata" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  name = "PII"
  description = "PII metadata"
  attribute_definition {
    name = "team"
  }
  attribute_definition {
    name = "email"
  }

  lifecycle {
    prevent_destroy = false
  }
}