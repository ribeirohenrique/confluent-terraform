variable "gcs_connectors" {
    description = "Topic Variables for tfvars file"
    type = map(object({
      confluent_cloud_api_key       = string
      confluent_cloud_api_secret    = string
      confluent_kafka_cluster       = string
      confluent_environment_id      = string
      varGcsCredentials             = any
      kafka_api_key                 = string
      kafka_api_secret              = string
      varNomeConector               = string
      varAuthMode                   = string
      varTopic                      = string
      varInputDataFormat            = string
      varOutputDataFormat           = string
      varGcsBucketName              = string
      varTimeInterval               = string
      varFlushSize                  = string
      varMaxTask                    = string
    }))
  
}