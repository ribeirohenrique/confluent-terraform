output "confluent_kafka_schema" {
  value = confluent_schema.avro_purchase
  sensitive = false
}
