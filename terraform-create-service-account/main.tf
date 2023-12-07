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


//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

//Cria uma Service Account
resource "confluent_service_account" "app_service_account" {
  display_name = var.service_account_name
  description  = "Service account to interact with ${var.cluster_id} cluster"
}

//Atribui a Service account criada acima a Role de Operator ao cluster
resource "confluent_role_binding" "app_service_account_kafka_cluster_admin" {
  count = var.role_name == "Operator" ? 1 : 0
  principal   = "User:${confluent_service_account.app_service_account.id}"
  role_name   = var.role_name
  crn_pattern = "${data.confluent_kafka_cluster.confluent_cluster.rbac_crn}/kafka=${data.confluent_kafka_cluster.confluent_cluster.id}"
}

//Atribui a Service account criada acima a Role de DeveloperWrite ao tópico
resource "confluent_role_binding" "app_service_account_kafka_cluster_admin" {
  count = var.role_name == "DeveloperWrite" || var.role_name == "DeveloperRead" ? 1 : 0
  principal   = "User:${confluent_service_account.app_service_account.id}"
  role_name   = var.role_name
  crn_pattern = "${data.confluent_kafka_cluster.confluent_cluster.rbac_crn}/kafka=${data.confluent_kafka_cluster.confluent_cluster.id}/topic=${var.topic_name}"
}

//Cria uma API Key a nível de Cluster
resource "confluent_api_key" "app_service_account_kafka_api_key" {
  display_name = "app_service_account_kafka_api_key"
  description  = "Kafka API Key that is owned by ${confluent_service_account.app_service_account.display_name} service account"
  owner {
    id          = confluent_service_account.app_service_account.id
    api_version = confluent_service_account.app_service_account.api_version
    kind        = confluent_service_account.app_service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.confluent_cluster.id
    api_version = data.confluent_kafka_cluster.confluent_cluster.api_version
    kind        = data.confluent_kafka_cluster.confluent_cluster.kind

    environment {
      id = var.environment_id
    }
  }

  depends_on = [
    confluent_role_binding.app_service_account_kafka_cluster_admin
  ]
}
