output "bigquery_connectors" {
  description = "Information about all bigquery connectors"
  value = { for k, b in confluent_connector.sink : k => {
    name     = b.config_nonsensitive["name"]
    topic    = b.config_nonsensitive["topics"]
    project  = b.config_nonsensitive["project"]
    datasets = b.config_nonsensitive["datasets"]
    }
  }
}