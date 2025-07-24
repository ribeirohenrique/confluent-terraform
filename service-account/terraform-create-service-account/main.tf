terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"

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