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

resource "confluent_tag_binding" "topic_tagging" {
  for_each    = var.topic_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${var.cluster_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "connector_tagging" {
  for_each    = var.connector_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "environment_tagging" {
  for_each    = var.environment_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "schema_tagging" {
  for_each    = var.schema_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:.:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag_binding" "cluster_link_tagging" {
  for_each = var.cluster_link_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_tag_binding" "cluster_tagging" {
  for_each = var.cluster_tags
  tag_name    = each.value.tag_name
  entity_name = "${var.schema_registry_id}:${each.key}"
  entity_type = each.value.entity_type

  lifecycle {
    prevent_destroy = false
  }
}