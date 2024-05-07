terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.74.0"
    }
  }
}

resource "confluent_connector" "sink" {
    for_each = { for k, v in var.gcs_connectors : k => v }
    environment {
      id = each.value.confluent_environment_id
    }
    kafka_cluster {
      id = each.value.confluent_kafka_cluster
    }

    config_sensitive = {
      "gcs.credentials.config" : each.value.varGcsCredentials,
      "kafka.api.key" : each.value.kafka_api_key,
      "kafka.api.secret" : each.value.kafka_api_secret
    }

    config_nonsensitive = {
      "name" : each.value.varNomeConector,
      "connector.class" : "GcsSink",
      "kafka.auth.mode" : "KAFKA_API_KEY",
      "topics" : each.value.varTopic,
      "input.data.format" : each.value.varInputDataFormat,
      "output.data.format" : each.value.varOutputDataFormat,
      "gcs.bucket.name" : each.value.varGcsBucketName,
      "time.interval" : each.value.varTimeInterval,
      "flush.size" : each.value.varFlushSize,
      "task.max" : each.value.varMaxTask
    }
  
}