terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
    }
  }
}

provider "confluent" {
  schema_registry_id            = var.schema_registry_id            # optionally use SCHEMA_REGISTRY_ID env var
  schema_registry_rest_endpoint = var.schema_registry_rest_endpoint # optionally use SCHEMA_REGISTRY_REST_ENDPOINT env var
  schema_registry_api_key       = var.schema_registry_api_key       # optionally use SCHEMA_REGISTRY_API_KEY env var
  schema_registry_api_secret    = var.schema_registry_api_secret    # optionally use SCHEMA_REGISTRY_API_SECRET env var
}


resource "confluent_subject_config" "subject_config" {
  subject_name        = "${var.subject_name}-value"
  compatibility_level = var.compatibility_level

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_schema" "schema_topic" {
  subject_name = "${var.subject_name}-value"
  format = "AVRO"
  schema = file(".\\schema\\${var.subject_name}.avsc")
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_subject_config.subject_config]
}