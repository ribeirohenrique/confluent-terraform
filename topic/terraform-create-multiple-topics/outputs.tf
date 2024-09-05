output "topics" {
  description = "Information about all topics"
  value = { for k, b in confluent_kafka_topic.topics : k => {
    topic_name       = b.topic_name
    partitions_count = b.partitions_count
  }
  }
}