terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//Obtendo dados necessários da Confluent
data "confluent_environment" "environment" {
  id = var.environment_id
}

data "confluent_kafka_cluster" "source" {
  id = var.source_kafka_cluster_id
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_kafka_cluster" "destination" {
  id = var.destination_kafka_cluster_id
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_service_account" "source_service_account" {
  id = var.source_service_account
}

data "confluent_service_account" "destination_service_account" {
  id = var.destination_service_account
}

resource "confluent_role_binding" "source_service_account_rb" {
  principal   = "User:${var.source_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.source.rbac_crn
}

resource "confluent_role_binding" "destination_service_account_rb" {
  principal   = "User:${var.destination_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.destination.rbac_crn
}

resource "confluent_api_key" "source_service_account_api_key" {
  display_name = "source_service_account_api_key"
  description  = "Kafka API Key that is owned by ${data.confluent_service_account.source_service_account.display_name} service account"
  owner {
    id          = data.confluent_service_account.source_service_account.id
    api_version = data.confluent_service_account.source_service_account.api_version
    kind        = data.confluent_service_account.source_service_account.kind
  }
  managed_resource {
    id          = data.confluent_kafka_cluster.source.id
    api_version = data.confluent_kafka_cluster.source.api_version
    kind        = data.confluent_kafka_cluster.source.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.source_service_account_rb
  ]
}

resource "confluent_api_key" "destination_service_account_api_key" {
  display_name = "destination_service_account_api_key"
  description  = "Kafka API Key that is owned by ${data.confluent_service_account.destination_service_account.display_name} service account"
  owner {
    id          = data.confluent_service_account.destination_service_account.id
    api_version = data.confluent_service_account.destination_service_account.api_version
    kind        = data.confluent_service_account.destination_service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.destination.id
    api_version = data.confluent_kafka_cluster.destination.api_version
    kind        = data.confluent_kafka_cluster.destination.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }
  depends_on = [
    confluent_role_binding.destination_service_account_rb
  ]
}

resource "confluent_cluster_link" "source_to_destination" {
  link_name = var.cluster_link_name
  link_mode = "BIDIRECTIONAL"
  local_kafka_cluster {
    id                 = data.confluent_kafka_cluster.source.id
    rest_endpoint      = data.confluent_kafka_cluster.source.rest_endpoint
    credentials {
      key    = confluent_api_key.source_service_account_api_key.id
      secret = confluent_api_key.source_service_account_api_key.secret
    }
  }
  remote_kafka_cluster {
    id                 = data.confluent_kafka_cluster.destination.id
    bootstrap_endpoint = data.confluent_kafka_cluster.destination.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }
  config = {
    "acl.sync.enable" : "true",
    "acl.sync.ms" : "5000",
    "auto.create.mirror.topics.enable" : "true",
    "topic.config.sync.ms" : "5000"
    "consumer.offset.sync.enable" : "true"
  }

  depends_on = [
    confluent_api_key.source_service_account_api_key,
    confluent_role_binding.source_service_account_rb
  ]
}
