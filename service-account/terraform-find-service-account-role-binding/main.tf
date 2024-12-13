terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.7.0"
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

//Busca uma Service Account
data "confluent_service_account" "app_service_account" {
  id = var.service_account_id
}

//Busca um tópico
data "confluent_kafka_topic" "confluent_topic" {
  topic_name    = var.topic_name
  rest_endpoint = var.rest_endpoint
  kafka_cluster {
    id = data.confluent_kafka_cluster.confluent_cluster.id
  }
  credentials {
    key    = var.kafka_api_key
    secret = var.kafka_api_secret

  }
}

data "confluent_role_binding" "search_role" {

}

//Atribui a Service account criada acima a Role de DeveloperWrite ou DeveloperRead ao tópico
resource "confluent_role_binding" "app_service_account_kafka_topic" {
  count = var.role_name == "DeveloperWrite" || var.role_name == "DeveloperRead" ? 1 : 0
  principal   = "User:${data.confluent_service_account.app_service_account.id}"
  role_name   = var.role_name
  crn_pattern = "${data.confluent_kafka_cluster.confluent_cluster.rbac_crn}/kafka=${data.confluent_kafka_cluster.confluent_cluster.id}/topic=${data.confluent_kafka_topic.confluent_topic.topic_name}"
}
