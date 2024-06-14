terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

provider "confluent" {
  kafka_id            = var.kafka_id
  kafka_rest_endpoint = var.kafka_rest_endpoint
  kafka_api_key       = var.cloud_api_key
  kafka_api_secret    = var.cloud_api_secret
}

data "confluent_kafka_topic" "topics" {
  for_each = var.topics
  kafka_cluster {
    id = var.kafka_id
  }
  rest_endpoint = var.kafka_rest_endpoint
  topic_name    = each.key
}

//fazer append do array no item que quer alterar
//conforme preenche no forms, adiciona dentro desta variavel
variable "temp_config" {
  type = map(string)
  default = {
    "max.message.bytes" = "7777776"
  }
}

resource "confluent_kafka_topic" "main" {
  for_each         = var.topics
  topic_name       = each.key
  partitions_count = each.value.partitions_count
  config           = merge(data.confluent_kafka_topic.topics[each.key].config, var.temp_config)

  lifecycle {
    prevent_destroy = true
  }
}