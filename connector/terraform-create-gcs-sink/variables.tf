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
    varClusterApiKey         = optional(string)
    varClusterApiSecret      = optional(string)
    confluent_kafka_cluster  = string
    confluent_environment_id = string
    varGcsCredentials        = any
    varNomeConector          = string
    varAuthMode              = string
    varTopic                 = string
    varInputDataFormat       = string
    varOutputDataFormat      = string
    varGcsBucketName         = string
    varTimeInterval          = string
    varFlushSize             = string
    varMaxTask               = string
    varServiceAccountId      = string
    varBucketFolder          = string
  }))

}