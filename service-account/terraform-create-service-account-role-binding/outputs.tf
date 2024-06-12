output "confluent_service_account_id" {
  value = data.confluent_service_account.app_service_account.id
}

output "confluent_service_account_display_name" {
  value = data.confluent_service_account.app_service_account.display_name
}

output "confluent_kafka_cluster_rbac_crn" {
  value = data.confluent_kafka_cluster.confluent_cluster.rbac_crn
}