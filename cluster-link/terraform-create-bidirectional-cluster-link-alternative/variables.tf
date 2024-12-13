# Variable for the above module
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

# This repo is for the creation of Clusterlink - Destination Initiated
# Variable for the above module
variable "cluster_links" {
  description = "Cluster link variables for tfvars file"
  type = map(object({
    source_kafka_api_key           : string  // Chave da API do cluster Kafka de origem
    source_kafka_api_secret        : string  // Segredo da API do cluster Kafka de origem
    destination_kafka_api_key      : string  // Chave da API do cluster Kafka de destino
    destination_kafka_api_secret   : string  // Segredo da API do cluster Kafka de destino
    environment_id                 : string  // ID do ambiente no Confluent Cloud
    varLinkName                    : string  // Nome do link que conecta os clusters
    source_kafka_cluster_id        : string  // ID do cluster Kafka de origem
    destination_kafka_cluster_id   : string  // ID do cluster Kafka de destino
    source_rest_endpoint           : string  // Endpoint REST do cluster Kafka de origem
    destination_bootstrap_endpoint : string  // Endpoint bootstrap do cluster Kafka de destino
    link_mode                      : string  // Modo do link (ex: BIDIRECTIONAL)
  }))
}

variable "topics" {
  description = "Topic details"
  type = map(object({
    topic_name       : string  // Nome do tópico Kafka no cluster de origem
    link_name        : string  // Nome do link associado ao tópico
    cluster_id       : string  // ID do cluster Kafka de origem para onde quer enviar o mirror
    rest_endpoint    : string  // Endpoint REST do cluster Kafka para onde quer enviar o mirror
    kafka_api_key    : string  // Chave da API Kafka para o tópico para onde quer enviar o mirror
    kafka_api_secret : string  // Segredo da API Kafka para o tópico para onde quer enviar o mirror
  }))
}