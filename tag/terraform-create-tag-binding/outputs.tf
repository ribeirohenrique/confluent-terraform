output "confluent_tag_id" {
  description = "Id do da tag criada"
  value = confluent_tag_binding.topic_tagging.id
}