output "kafka_topics_RESULTADO" {
  description = "Map of created Confluent Kafka topics"
  value = { for k, b in confluent_kafka_topic.main : k => {
    config = b.config
    }
  }
}

output "kafka_topics_datasource_ANTES" {
  description = "Map of created Confluent Kafka topics"
  value = { for k, b in data.confluent_kafka_topic.topics : k => {
    config = b.config
    }
  }
}

output "merge_test_DEPOIS" {
  description = "test"
    value = { for k, b in data.confluent_kafka_topic.topics : k => {
    config = merge(data.confluent_kafka_topic.topics[b.topic_name].config, var.temp_config)
    }
  }

}