output "id" {
  value = data.confluent_subject_mode.subject_mode.id
}

output "mode" {
  value = data.confluent_subject_mode.subject_mode.mode
}

output "schema_registry_cluster" {
  value = data.confluent_subject_mode.subject_mode.schema_registry_cluster
}

output "rest_endpoint" {
  value = data.confluent_subject_mode.subject_mode.rest_endpoint
}

output "subject_name" {
  value = data.confluent_subject_mode.subject_mode.subject_name
}