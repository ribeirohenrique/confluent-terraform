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

data "confluent_schemas" "all_schemas" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.schema_registry_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint

  filter {
    subject_prefix = ""    # Deixe vazio para pegar todos os schemas
    latest_only    = false # Para trazer todas as versões de cada schema
    deleted        = false  # Exclua schemas deletados
  }

  credentials {
    key    = var.schema_api_key
    secret = var.schema_api_secret
  }
}

resource "null_resource" "delete_schema_version" {
  for_each = { for idx, schema in var.schemas_to_delete : "${schema.subject_name}:${schema.version}" => schema }

  provisioner "local-exec" {
    command = <<EOT
      ./delete_schema.sh \
        "${data.confluent_schema_registry_cluster.schema_registry_cluster.rest_endpoint}" \
        "${var.schema_api_key}" \
        "${var.schema_api_secret}" \
        "${each.value.subject_name}" \
        "${each.value.version}"
    EOT
  }
}

