output "gcs_connectors" {
  description = "Information about all gcs connectors"
  value       = {
    for k, b in confluent_connector.source : k => {
      name            = b.config_nonsensitive["name"]
      gcs-bucket-name = b.config_nonsensitive["gcs.bucket.name"]
    }
  }

}
