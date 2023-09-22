terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.52.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_service_account" "app-sink-rb" {
  display_name = "app-sink-rb"
  description  = "Service account to manage 'sink-connectors' Kafka cluster"
}

resource "confluent_service_account" "app-source-rb" {
  display_name = "app-source-rb"
  description  = "Service account to manage 'sink-connectors' Kafka cluster"
}

resource "confluent_role_binding" "app-sink-rb" {
  principal   = "User:${confluent_service_account.app-sink-rb.id}"
  role_name   = "DeveloperRead"
  crn_pattern = var.confluent_crn
}

resource "confluent_role_binding" "app-source-rb" {
  principal   = "User:${confluent_service_account.app-source-rb.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = var.confluent_crn
}


resource "confluent_role_binding" "group-source-rb" {
  principal = "User:${confluent_service_account.app-source-rb.id}"
  role_name = "DeveloperRead"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${var.confluent_crn_rb}/group=confluent_cli_consumer_*"
}


resource "confluent_role_binding" "connector-source-rb" {
  principal   = "User:${confluent_service_account.app-source-rb.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${var.confluent_crn_rb}/connector=${confluent_connector.source.id}"
}

resource "confluent_connector" "source" {
  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.cluster_id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSource-rb"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-source-rb.id
    "kafka.topic"              = var.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }

  depends_on = [ confluent_service_account.app-source-rb,  confluent_role_binding.group-source-rb]
}