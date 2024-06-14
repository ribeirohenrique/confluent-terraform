output "topics" {
  description = "Information about all topics"
  value = { for k, t in confluent_kafka_topic.main : k => {
    topic_name       = t.topic_name
    partitions_count = t.partitions_count
    config           = t.config
    }
  }
}