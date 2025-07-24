terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"

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

resource "confluent_tag" "tagging" {
  for_each    = var.tags
  name        = each.key
  description = each.value.description

  lifecycle {
    prevent_destroy = true
  }
}
