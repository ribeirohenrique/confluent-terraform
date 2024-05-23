terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  schema_registry_id            = var.schema_registry_id            # optionally use SCHEMA_REGISTRY_ID env var
  schema_registry_rest_endpoint = var.schema_registry_rest_endpoint # optionally use SCHEMA_REGISTRY_REST_ENDPOINT env var
  schema_registry_api_key       = var.schema_registry_api_key       # optionally use SCHEMA_REGISTRY_API_KEY env var
  schema_registry_api_secret    = var.schema_registry_api_secret    # optionally use SCHEMA_REGISTRY_API_SECRET env var
}

resource "confluent_tag_binding" "topic_tagging" {
  tag_name    = "PRD"
  entity_name = "${var.schema_registry_id}:${var.cluster_id}:${var.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    prevent_destroy = false
  }
}
