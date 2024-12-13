output "confluent_topic_id" {
  description = "Id do tópico criado"
  value = confluent_kafka_topic.confluent_topic.id
}