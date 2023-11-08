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

data "confluent_kafka_cluster" "shared_des" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

// 'app_manager' service account is required in this configuration to create var.topic_name topic and grant ACLs
// to 'app_producer' and 'app_consumer' service accounts.
resource "confluent_service_account" "app_manager" {
  display_name = "app_${var.topic_name}_manager"
  description  = "Service account to manage ${var.cluster_id} Kafka cluster"
}

resource "confluent_role_binding" "app_manager_kafka_cluster_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.shared_des.rbac_crn
}


resource "confluent_api_key" "app_manager_kafka_api_key" {
  display_name = "app_manager_kafka_api_key"
  description  = "Kafka API Key that is owned by ${confluent_service_account.app_manager.display_name} service account"
  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.shared_des.id
    api_version = data.confluent_kafka_cluster.shared_des.api_version
    kind        = data.confluent_kafka_cluster.shared_des.kind

    environment {
      id = var.environment_id
    }
  }

  # The goal is to ensure that confluent_role_binding.app_manager_kafka_cluster_admin is created before
  # confluent_api_key.app_manager_kafka_api_key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta_argument is specified in confluent_api_key.app_manager_kafka_api_key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app_manager_kafka_cluster_admin
  ]
}

resource "confluent_service_account" "app_consumer" {
  display_name = "app_${var.topic_name}_consumer"
  description  = "Service account to consume from '${var.topic_name}' topic of ${var.cluster_id} Kafka cluster"
}

resource "confluent_api_key" "app_consumer_kafka_api_key" {
  display_name = "${confluent_service_account.app_consumer.display_name}_kafka_api_key"
  description  = "Kafka API Key that is owned by ${confluent_service_account.app_consumer.display_name} service account"
  owner {
    id          = confluent_service_account.app_consumer.id
    api_version = confluent_service_account.app_consumer.api_version
    kind        = confluent_service_account.app_consumer.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.shared_des.id
    api_version = data.confluent_kafka_cluster.shared_des.api_version
    kind        = data.confluent_kafka_cluster.shared_des.kind

    environment {
      id = var.environment_id
    }
  }
}

resource "confluent_service_account" "app_producer" {
  display_name = "app_${var.topic_name}_producer"
  description  = "Service account to produce to '${var.topic_name}' topic of ${var.cluster_id} Kafka cluster"
}

resource "confluent_api_key" "app_producer_kafka_api_key" {
  display_name = "${confluent_service_account.app_producer.display_name}_kafka_api_key"
  description  = "Kafka API Key that is owned by ${confluent_service_account.app_producer.display_name} service account"
  owner {
    id          = confluent_service_account.app_producer.id
    api_version = confluent_service_account.app_producer.api_version
    kind        = confluent_service_account.app_producer.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.shared_des.id
    api_version = data.confluent_kafka_cluster.shared_des.api_version
    kind        = data.confluent_kafka_cluster.shared_des.kind

    environment {
      id = var.environment_id
    }
  }
}

resource "confluent_kafka_topic" "connector_topic" {
  kafka_cluster {
    id = var.cluster_id
  }

  topic_name    = var.topic_name
  rest_endpoint = data.confluent_kafka_cluster.shared_des.rest_endpoint
  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }
}


// Note that in order to consume from a topic, the principal of the consumer ('app_consumer' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
resource "confluent_role_binding" "app_consumer_developer_read_from_topic" {
  principal   = "User:${confluent_service_account.app_consumer.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${data.confluent_kafka_cluster.shared_des.rbac_crn}/kafka=${data.confluent_kafka_cluster.shared_des.id}/topic=${confluent_kafka_topic.connector_topic.topic_name}"
}

resource "confluent_role_binding" "app_consumer_developer_read_from_group" {
  principal = "User:${confluent_service_account.app_consumer.id}"
  role_name = "DeveloperRead"
  // The existing value of crn_pattern's suffix (group=confluent_cli_consumer_*) are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent_cli/current/command_reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update it to match your target consumer group ID.
  crn_pattern = "${data.confluent_kafka_cluster.shared_des.rbac_crn}/kafka=${data.confluent_kafka_cluster.shared_des.id}/group=confluent_cli_consumer_*"
}