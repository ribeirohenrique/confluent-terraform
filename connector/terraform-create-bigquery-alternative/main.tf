terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"

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
    "topics" : each.value.topic_name,
    "schema.context.name": "default",
    "input.key.format": "AVRO",
    "input.data.format": "AVRO",
    "connector.class" : "BigQueryStorageSink",
    "name" : each.value.connector_name,
    "kafka.auth.mode" : "SERVICE_ACCOUNT",
    "kafka.service.account.id" = each.value.service_account_id,
    "authentication.method": "Google cloud service account",
    "project" : each.value.gcp_project_id,
    "datasets" : each.value.gcp_dataset,
    "ingestion.mode": "BATCH LOADING",
    "topic2table.map": "bigquery_topic:bigqquery_table",
    "sanitize.topics" : each.value.sanitize_topics,
    "sanitize.field.names" : each.value.sanitize_field_names,
    "auto.create.tables" : each.value.auto_create_tables,
    "auto.update.schemas" : each.value.auto_update_schemas,
    "partitioning.type": "HOUR",
    "max.poll.interval.ms": "300000",
    "max.poll.records": "500",
    "tasks.max" : each.value.task_max
  }

}
