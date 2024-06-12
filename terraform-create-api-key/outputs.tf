output "confluent_kafka_cluster_rbac_crn" {
  value = data.confluent_kafka_cluster.confluent_cluster.rbac_crn
  sensitive = false
}

output "confluent_api_key_id" {
  value = confluent_api_key.app_service_account_kafka_api_key.id
  sensitive = false
}

output "confluent_api_key_secret" {
  value = confluent_api_key.app_service_account_kafka_api_key.secret
  sensitive = true
}

output "confluent_api_key_display_name" {
  value = confluent_api_key.app_service_account_kafka_api_key.display_name
  sensitive = false
}