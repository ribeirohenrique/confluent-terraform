terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.7.0"
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

/*data "confluent_schemas" "get_schema_details" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint

  filter {
    subject_prefix = "restaurant-schema"
    latest_only    = true
    deleted        = false
  }

  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }
}*/

data "confluent_subject_mode" "subject_mode" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  subject_name = "testing-schema-value"
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }
}