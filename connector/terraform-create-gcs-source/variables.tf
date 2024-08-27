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

variable "gcs_connectors" {
  description = "Topic Variables for tfvars file"
  type = map(object({
    confluent_environment_id = string
    confluent_kafka_cluster  = string
    varGcsCredentials        = any
    varGcsBucketName         = string
    varInputDataFormat       = string
    varAuthMode              = string
    varServiceAccountId      = string
    varNomeConector          = string
    varOutputDataFormat      = string
    varMaxTask               = string
    varTopicRegexList        = string
    varGcsTopLevelDirectory  = string
  }))

}
