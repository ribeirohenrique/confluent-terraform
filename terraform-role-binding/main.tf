terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.55.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_service_account" "app-creator" {
  display_name = "app-creator"
  description  = "Service account to manage 'creations' inside Kafka cluster"
}

resource "confluent_service_account" "app-sink-rb" {
  display_name = "app-sink-rb"
  description  = "Service account to manage 'sink-connectors' Kafka cluster"
}

resource "confluent_service_account" "app-source-rb" {
  display_name = "app-source-rb"
  description  = "Service account to manage 'source-connectors' Kafka cluster"
}

resource "confluent_role_binding" "app-creator" {
  principal   = "User:${confluent_service_account.app-creator.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "crn://confluent.cloud/organization=${var.organization_id}/environment=${var.environment_id}/cloud-cluster=${var.cluster_id}/kafka=${var.cluster_id}"
}

resource "confluent_role_binding" "app-sink-rb" {
  principal   = "User:${confluent_service_account.app-sink-rb.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "crn://confluent.cloud/organization=${var.organization_id}/environment=${var.environment_id}/cloud-cluster=${var.cluster_id}/kafka=${var.cluster_id}"
}

resource "confluent_role_binding" "app-source-rb" {
  principal   = "User:${confluent_service_account.app-source-rb.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "crn://confluent.cloud/organization=${var.organization_id}/environment=${var.environment_id}/cloud-cluster=${var.cluster_id}/kafka=${var.cluster_id}"
}


resource "confluent_role_binding" "group-source-rb" {
  principal   = "User:${confluent_service_account.app-source-rb.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "crn://confluent.cloud/organization=${var.organization_id}/environment=${var.environment_id}/cloud-cluster=${var.cluster_id}/kafka=${var.cluster_id}/group=${var.consumer_group_id}"
}


resource "confluent_role_binding" "connector-source-rb" {
  principal   = "User:${confluent_service_account.app-source-rb.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${var.organization_id}/connector=${confluent_connector.source.id}"
}

resource "confluent_api_key" "app-creator" {
  display_name = "app-creator"
  description  = "Kafka API Key that is owned by 'app-creator' service account"
  owner {
    id          = confluent_service_account.app-creator.id
    api_version = confluent_service_account.app-creator.api_version
    kind        = confluent_service_account.app-creator.kind
  }

  managed_resource {
    id          = var.cluster_id
    api_version = "cmk/v2"
    kind        = "Cluster"

    environment {
      id = var.environment_id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_api_key" "app-source-api-key" {
  display_name = "app-source-api-key"
  description  = "Kafka API Key that is owned by 'app-source' service account"
  owner {
    id          = confluent_service_account.app-source-rb.id
    api_version = confluent_service_account.app-source-rb.api_version
    kind        = confluent_service_account.app-source-rb.kind
  }

  managed_resource {
    id          = var.cluster_id
    api_version = "cmk/v2"
    kind        = "Cluster"

    environment {
      id = var.environment_id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_api_key" "app-sink-api-key" {
  display_name = "app-sink-api-key"
  description  = "Kafka API Key that is owned by 'app-sink' service account"
  owner {
    id          = confluent_service_account.app-sink-rb.id
    api_version = confluent_service_account.app-sink-rb.api_version
    kind        = confluent_service_account.app-sink-rb.kind
  }

  managed_resource {
    id          = var.cluster_id
    api_version = "cmk/v2"
    kind        = "Cluster"

    environment {
      id = var.environment_id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_kafka_topic" "connector-topic" {
  kafka_cluster {
    id = var.cluster_id
  }
  topic_name       = var.topic_name
  rest_endpoint    = var.rest_endpoint
  partitions_count = 2
  credentials {
    key    = confluent_api_key.app-creator.id
    secret = confluent_api_key.app-creator.secret
  }
  config = {
    "cleanup.policy"                      = "delete"
    "delete.retention.ms"                 = "86400000"
    "max.compaction.lag.ms"               = "9223372036854775807"
    "max.message.bytes"                   = "2097164"
    "message.timestamp.difference.max.ms" = "9223372036854775807"
    "message.timestamp.type"              = "CreateTime"
    "min.compaction.lag.ms"               = "0"
    "min.insync.replicas"                 = "2"
    "retention.bytes"                     = "-1"
    "retention.ms"                        = "604800000"
    "segment.bytes"                       = "104857600"
    "segment.ms"                          = "604800000"
  }


  lifecycle {
    prevent_destroy = false
  }

  depends_on = []
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
    "name"                     = "DatagenSource"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-source-rb.id
    "kafka.topic"              = confluent_kafka_topic.connector-topic.id
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }

  depends_on = [confluent_service_account.app-creator, confluent_kafka_topic.connector-topic]
}
