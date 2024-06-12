output "gcs_connectors" {
  description = "Information about all gcs connectors"
  value = { for k, b in confluent_connector.sink : k => {
    name            = b.config_nonsensitive["name"]
    topic           = b.config_nonsensitive["topics"]
    gcs-bucket-name = b.config_nonsensitive["gcs.bucket.name"]
  } }

}
