output "schemas" {
  description = "Information about all schemas"
  value       = confluent_schema.schema_topic
}

output "schemas_configurations" {
  description = "Information about all schemas configurations"
  value = confluent_subject_config.subject_config.subject_name
}