terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
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

//Define a Service Account a ser utilizado
data "confluent_service_account" "confluent_service_account" {
  display_name = var.service_account_name
}

//Cria uma API Key a nível de Cluster
resource "confluent_api_key" "app_service_account_kafka_api_key" {
  display_name = "app_service_account_kafka_api_key"
  description  = "Kafka API Key that is owned by ${data.confluent_service_account.confluent_service_account.id} service account"
  owner {
    id          = data.confluent_service_account.confluent_service_account.id
    api_version = data.confluent_service_account.confluent_service_account.api_version
    kind        = data.confluent_service_account.confluent_service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.confluent_cluster.id
    api_version = data.confluent_kafka_cluster.confluent_cluster.api_version
    kind        = data.confluent_kafka_cluster.confluent_cluster.kind

    environment {
      id = var.environment_id
    }
  }
}
