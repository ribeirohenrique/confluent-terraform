output "confluent_service_account_id" {
  value = confluent_service_account.app_service_account.id
}

output "confluent_service_account_display_name" {
  value = confluent_service_account.app_service_account.display_name
}

output "confluent_kafka_cluster_rbac_crn" {
  value = data.confluent_kafka_cluster.confluent_cluster.rbac_crn
}

output "confluent_api_key_id" {
  value = confluent_api_key.app_service_account_kafka_api_key.id
}

output "confluent_api_key_display_name" {
  value = confluent_api_key.app_service_account_kafka_api_key.display_name
}