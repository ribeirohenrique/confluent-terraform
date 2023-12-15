terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.55.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_connector" "sink" {
  for_each = { for k, v in var.bigquery_connectors : k => v }
  environment {
    id = each.value.environment_id
  }
  kafka_cluster {
    id = each.value.cluster_id
  }

  config_sensitive = {
    "keyfile" : jsonencode(each.value.gcp_keyfile)
  }

  config_nonsensitive = {
    "name" : each.value.connector_name,
    "connector.class" : "BigQuerySink",
    "kafka.auth.mode" : "SERVICE_ACCOUNT",
    "kafka.service.account.id" = each.value.service_account_id,
    "topics" : each.value.topic_name,
    "project" : each.value.gcp_project_id,
    "datasets" : each.value.gcp_dataset,
    "input.data.format" : each.value.input_data_format,
    "auto.create.tables" : each.value.auto_create_tables,
    "sanitize.topics" : each.value.sanitize_topics,
    "auto.update.schemas" : each.value.auto_update_schemas,
    "sanitize.field.names" : each.value.sanitize_field_names,
    "tasks.max" : each.value.task_max
  }

}
