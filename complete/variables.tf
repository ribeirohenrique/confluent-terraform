variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "cluster_display_name" {
  description = "Cluster Name"
  type        = string
  sensitive   = false
}

variable "environment_display_name" {
  description = "Environment Name"
  type        = string
  sensitive   = false
}

variable "environment_stream_governance_type" {
  description = "Cluster Name"
  type        = string
  default     = "Essentials"
  sensitive   = false

  validation {
    condition     = contains(["ESSENTIALS", "ADVANCED"], var.environment_stream_governance_type)
    error_message = "The environment_stream_governance_type must be either 'ESSENTIALS' or 'ADVANCED'."
  }
}

variable "cluster_availability" {
  description = "Cluster Name"
  type        = string
  default     = "SINGLE_ZONE"
  sensitive   = false

  validation {
    condition     = contains(["SINGLE_ZONE", "MULTI_ZONE"], var.cluster_availability)
    error_message = "The cluster_availability must be either 'SINGLE_ZONE' or 'MULTI_ZONE'."
  }
}

variable "cluster_cloud_provider" {
  description = "Cloud Cluster Provider"
  type        = string
  sensitive   = false

  validation {
    condition     = contains(["GCP", "AWS", "AZURE"], var.cluster_cloud_provider)
    error_message = "The cluster_availability must be either 'GCP', 'AWS' or 'AZURE'."
  }
}

variable "cluster_cloud_region" {
  description = "Cloud Cluster Region. See more at https://docs.confluent.io/cloud/current/clusters/regions.html#cloud-providers-and-regions"
  type        = string
  sensitive   = false
}

variable "cluster_num_ckus" {
  description = "Number of CKUs for the dedicated cluster"
  type        = string
  sensitive   = false
  default     = "1"
}

variable "network_connection_type" {
  description = "Network Connection Type for the cluster (required for VPC and Subnet)"
  type        = string
  sensitive   = false
}

variable "network_zones" {
  description = "A list of zones to configure the network."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "service_account_name" {
  description = "Service Account Name"
  type        = string
  sensitive   = false
}

variable "service_account_role_name" {
  description = "Service Account role Name"
  type        = string
  sensitive   = false
}

variable "topic_name" {
  description = "Topic Name"
  type        = string
  sensitive   = false
}

variable "topic_partitions" {
  description = "Topic Partitions count"
  type        = string
  sensitive   = false
}


variable "tag_name" {
  description = "Tag Name"
  type        = string
  sensitive   = false
}

variable "schema_registry_package" {
  description = "Schema registry package"
  type        = string
  sensitive   = false
  validation {
    condition     = contains(["ESSENTIALS", "ADVANCED"], var.schema_registry_package)
    error_message = "The network connection type must be either 'ESSENTIALS' or 'ADVANCED'."
  }
}

variable "schema_path" {
  description = "AVRO Schema path"
  type        = string
  sensitive   = false
}