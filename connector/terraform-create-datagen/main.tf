terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}


//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "shared_des" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}


//Cria uma Service Account para gerenciar os acessos
resource "confluent_service_account" "app_manager" {
  display_name = "app_${var.topic_name}_manager"
  description  = "Service account to manage ${var.cluster_id} Kafka cluster"
}

//Atribui a Service account criada acima a Role de CloudClusterAdmin
resource "confluent_role_binding" "app_manager_kafka_cluster_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.shared_des.rbac_crn
}

//Cria uma API Key a nível de Cluster
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

//Cria uma Service Account para consumir dados
resource "confluent_service_account" "app_consumer" {
  display_name = "app_${var.topic_name}_consumer"
  description  = "Service account to consume from '${var.topic_name}' topic of ${var.cluster_id} Kafka cluster"
}

//Cria uma API Key a nível de Cluster
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

//Cria uma Service Account para consumir dados
resource "confluent_service_account" "app_producer" {
  display_name = "app_${var.topic_name}_producer"
  description  = "Service account to produce to '${var.topic_name}' topic of ${var.cluster_id} Kafka cluster"
}

//Cria uma API Key a nível de Cluster
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

//Cria um tópico para gravar mensagens
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

//Atribui a Service account app_consumer a Role de DeveloperRead
resource "confluent_role_binding" "app_consumer_developer_read_from_topic" {
  principal   = "User:${confluent_service_account.app_consumer.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${data.confluent_kafka_cluster.shared_des.rbac_crn}/kafka=${data.confluent_kafka_cluster.shared_des.id}/topic=${confluent_kafka_topic.connector_topic.topic_name}"
}

//Atribui a Service account app_producer a Role de DeveloperWrite
resource "confluent_role_binding" "app_consumer_developer_write_to_topic" {
  principal   = "User:${confluent_service_account.app_producer.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${data.confluent_kafka_cluster.shared_des.rbac_crn}/kafka=${data.confluent_kafka_cluster.shared_des.id}/topic=${confluent_kafka_topic.connector_topic.topic_name}"
}

//Cria o conector DatagenSource utilizando a service account app_producer
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
    "name"                     = "DatagenTerraform"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app_producer.id
    "kafka.topic"              = var.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }

  lifecycle {
    prevent_destroy = false
  }
}
