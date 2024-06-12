output "pubsub_connectors" {
  description = "Information about all pubsub connectors"
  value = { for k, b in confluent_connector.source : k => {
    name                  = b.config_nonsensitive["name"]
    kafka-topic           = b.config_nonsensitive["kafka.topic"]
    gcp-pubsub-project-id = b.config_nonsensitive["gcp.pubsub.project.id"]
    gcp-pubsub-topic-id   = b.config_nonsensitive["gcp.pubsub.topic.id"]
    }
  }
}
