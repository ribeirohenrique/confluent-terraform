output "schemas" {
  value = [
    for schema in data.confluent_schemas.all_schemas.schemas : {
      schema_identifier = schema.schema_identifier
      schema_reference  = schema.schema_reference
      subject_name      = schema.subject_name
      version           = schema.version
    }
  ]
}
