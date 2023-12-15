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

resource "confluent_connector" "source" {
  for_each = { for k, v in var.pubsub_connectors : k => v }
  environment {
    id = each.value.confluent_environment_id
  }
  kafka_cluster {
    id = each.value.confluent_kafka_cluster_id
  }

  config_sensitive = {
    "gcp.pubsub.credentials.json" : jsonencode(each.value.keyfile)
  }

  config_nonsensitive = {
    "name" : each.value.connector_name,
    "connector.class" : "PubSubSource",
    "kafka.auth.mode" : "SERVICE_ACCOUNT",
    "kafka.service.account.id" = each.value.service_account_id,
    "kafka.topic" : each.value.topic_name,
    "gcp.pubsub.project.id" : each.value.gcp_project_id,
    "gcp.pubsub.topic.id" : each.value.gcp_topic_id,
    "gcp.pubsub.subscription.id" : each.value.gcp_subscription_id,
    "tasks.max" : each.value.task_max
  }
}
