output "confluent_tag_id" {
  description = "Id da tag criada"
  value = confluent_tag.tagging.id
}
output "confluent_tag_name" {
  description = "Name da tag criada"
  value = confluent_tag.tagging.name
}
