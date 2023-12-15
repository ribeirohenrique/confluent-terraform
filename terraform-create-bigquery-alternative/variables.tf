# Variable for the above module
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "bigquery_connectors" {
  description = "Bigquery connectors variables for tfvars file"
  type = map(object({
    organization_id      = string
    rest_endpoint        = string
    cluster_id           = string
    environment_id       = string
    service_account_id   = string
    gcp_keyfile          = any
    connector_name       = string
    topic_name           = string
    gcp_project_id       = string
    gcp_dataset          = string
    input_data_format    = string
    auto_create_tables   = bool
    sanitize_topics      = bool
    auto_update_schemas  = bool
    sanitize_field_names = bool
    task_max             = string
  }))

}
