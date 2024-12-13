terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.7.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.cloud_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.cloud_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

data "confluent_schemas" "getAll" {
  schema_registry_cluster {
    id = var.schema_registry_id
  }
  rest_endpoint = var.schema_registry_rest_endpoint

  filter {
    subject_prefix = var.subject_name
    latest_only    = false
    deleted        = true
  }

  credentials {
    key    = var.schema_registry_api_key
    secret = var.schema_registry_api_secret
  }
}

