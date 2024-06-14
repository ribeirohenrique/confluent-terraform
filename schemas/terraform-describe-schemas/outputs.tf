output "schemas" {
  value = data.confluent_schemas.getAll.schemas
}