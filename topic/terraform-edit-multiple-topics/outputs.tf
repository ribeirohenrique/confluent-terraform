output "topics_retrieved_confluent" {
  description = "Map of existing Confluent Kafka topics"
  value = { for k, b in data.confluent_kafka_topic.get_topics : k => {
    config = b.config
    }
  }
}

output "kafka_topics_modified" {
  description = "Map of created Confluent Kafka topics"
  value = { for k, b in confluent_kafka_topic.modify_topic : k => {
    config = b.config
    }
  }
}

output "kafka_topics_created" {
  description = "Map of created Confluent Kafka topics"
  value = { for k, b in confluent_kafka_topic.create_topic : k => {
    config = b.config
    }
  }
}

output "merge_test_variable_visualize" {
  description = "Output to see the result of merge"
    value = { for k, b in data.confluent_kafka_topic.get_topics : k => {
    config = merge(data.confluent_kafka_topic.get_topics[b.topic_name].config, var.modify_params)
    }
  }
}