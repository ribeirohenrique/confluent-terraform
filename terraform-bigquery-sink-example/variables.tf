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
variable "confluent_environment_id" {
    description = "Environment Id env-m8jro2"
    type = string
    sensitive = false
}

variable "input_key_format" {
  description = "Input Key Format"
  type = string
  sensitive = false
}

variable "input_data_format" {
  description = "Input Data Format"
  type = string
  sensitive = false
}

variable "connector_name" {
  description = "Connector Name"
  type = string
  sensitive = false
}

variable "gcp_keyfile" {
  description = "GCP Secret"
  type = string
  sensitive = true
}

variable "gcp_proj_id" {
  description = "GCP project ID"
  type = string
  sensitive = true
}

variable "gcp_dataset" {
  description = "GCP Dataset Name"
  type = string
  sensitive = true
}

variable "crn_pattern"{
  description = "Confluent Resource Name"
  type = string
  sensitive = false
}