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

/*resource "confluent_catalog_entity_attributes" "environments" {
  for_each = var.environments
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  entity_name = each.key
  entity_type = "cf_environment"
  attributes = {
    "description" = each.value.environment_description
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_catalog_entity_attributes" "connectors" {
  for_each = var.connectors
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  entity_name = each.key
  entity_type = "cn_connector"
  attributes = {
    "description" = each.value.connector_description
  }

  lifecycle {
    prevent_destroy = false
  }
}*/

resource "confluent_catalog_entity_attributes" "cluster_link" {
  for_each = var.cluster_link
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  entity_name = "${data.confluent_kafka_cluster.cluster.id}:${each.key}"
  entity_type = "kafka_cluster_link"
  attributes = {
    "description" = each.value.clusterlink_description
  }

  lifecycle {
    prevent_destroy = false
  }
}


/*resource "confluent_catalog_entity_attributes" "kafka-clusters" {
  for_each = var.clusters
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }
  entity_name = each.key
  entity_type = "kafka_logical_cluster"
  attributes = {
    "description" = each.value.cluster_description
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_catalog_entity_attributes" "topics" {
  for_each = var.topics
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
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

resource "confluent_catalog_entity_attributes" "schemas" {
  for_each = var.schemas
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint
  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }

  entity_name = "${data.confluent_schema_registry_cluster.schema_registry_cluster.id}:.:${each.key}"
  entity_type = "sr_schema"
  attributes = {
    "description" = each.value.schema_description
  }

  lifecycle {
    prevent_destroy = false
  }
}*/