terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}


//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//Recupera dados do cluster informado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  environment {
    id = var.gcs_connectors.gcs_sink_1.confluent_environment_id
  }
}

//Cria o conector
resource "confluent_connector" "sink" {
  for_each = { for k, v in var.gcs_connectors : k => v }
  environment {
    id = each.value.confluent_environment_id
  }
  kafka_cluster {
    id = each.value.confluent_kafka_cluster
  }

  config_sensitive = {
    "gcs.credentials.config" : each.value.varGcsCredentials,
  }

  config_nonsensitive = {
    "name" : each.value.varNomeConector,
    "connector.class" : "GcsSink",
    "schema.context.name" : "default"
    "topics.dir" : each.value.varBucketFolder
    "path.format" : "'dt'=YYYY-MM/'day'=dd/'hour'=HH"
    "kafka.auth.mode" : each.value.varAuthMode,
    "kafka.service.account.id" : each.value.varServiceAccountId,
    "topics" : each.value.varTopic,
    "input.data.format" : each.value.varInputDataFormat,
    "output.data.format" : each.value.varOutputDataFormat,
    "gcs.bucket.name" : each.value.varGcsBucketName,
    "time.interval" : each.value.varTimeInterval,
    "flush.size" : each.value.varFlushSize,
    "tasks.max" : each.value.varMaxTask
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "describe_cluster" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "read_topic" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = var.gcs_connectors.gcs_sink_1.varTopic
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "create_dlq" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "write_dlq" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "dlq-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "create_success" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "write_success" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "success-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "create_error" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "write_error" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "TOPIC"
  resource_name = "error-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui as devidas permissões para a Service Account
resource "confluent_kafka_acl" "read_consumer" {
  kafka_cluster {
    id = var.gcs_connectors.gcs_sink_1.confluent_kafka_cluster
  }
  resource_type = "GROUP"
  resource_name = "connect-lcc-${confluent_connector.sink["gcs_sink_1"].id}"
  pattern_type  = "LITERAL"
  principal     = "User:${var.gcs_connectors.gcs_sink_1.varServiceAccountId}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
  credentials {
    key    = var.gcs_connectors.gcs_sink_1.varClusterApiKey
    secret = var.gcs_connectors.gcs_sink_1.varClusterApiSecret
  }

  lifecycle {
    prevent_destroy = false
  }
}