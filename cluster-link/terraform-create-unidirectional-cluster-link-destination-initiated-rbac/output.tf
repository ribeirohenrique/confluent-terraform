// Outputs
output "source_environment_id" {
  value = data.confluent_environment.source_environment.id
  sensitive = true
}

output "source_kafka_cluster_id" {
  value = data.confluent_kafka_cluster.source_cluster.id
}

output "source_service_account_id" {
  value = data.confluent_service_account.source_service_account.id
}

output "destination_environment_id" {
  value = data.confluent_environment.destination_environment.id
  sensitive = true
}

output "destination_kafka_cluster_id" {
  value = data.confluent_kafka_cluster.destination_cluster.id
}

output "destination_service_account_id" {
  value = data.confluent_service_account.destination_service_account.id
}

output "source_service_account_role_binding" {
  value = confluent_role_binding.source_service_account_rb
}

output "source_service_account_api_key_id" {
  value = confluent_api_key.source_service_account_api_key.id
}

output "destination_service_account_api_key_id" {
  value = confluent_api_key.destination_service_account_api_key.id
}

output "cluster_link_id" {
  value = confluent_cluster_link.source_to_destination.link_name
}

output "mirror_topic_source_id" {
  value = var.create_mirror_topic ? confluent_kafka_mirror_topic.mirror_topic_source[0].id : null
}

