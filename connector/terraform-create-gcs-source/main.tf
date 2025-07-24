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

resource "confluent_connector" "source" {
  for_each = {for k, v in var.gcs_connectors : k => v}
  environment {
    id = each.value.confluent_environment_id
  }
  kafka_cluster {
    id = each.value.confluent_kafka_cluster
  }

  config_sensitive = {
    "gcs.credentials.json" : each.value.varGcsCredentials,
  }

  config_nonsensitive = {
    "behavior.on.error" : "LOG",
    "connector.class" : "GcsSource",
    "gcs.bucket.name" : each.value.varGcsBucketName,
    "input.data.format" : each.value.varInputDataFormat,
    "output.data.format" : each.value.varOutputDataFormat,
    "kafka.auth.mode" : each.value.varAuthMode,
    "kafka.service.account.id" : each.value.varServiceAccountId,
    "name" : each.value.varNomeConector,
    "schema.context.name" : "default",
    "tasks.max" : each.value.varMaxTask,
    "topic.regex.list" : each.value.varTopicRegexList,
    "topics.dir" : each.value.varGcsTopLevelDirectory
  }

}
