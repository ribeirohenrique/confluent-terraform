terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.52.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//cria o environment, onde ficará o cluster
resource "confluent_environment" "bigquery-terraform" {
  display_name = "bigquery-terraform"
}

//cria o cluster, onde ficará o tópico
resource "confluent_kafka_cluster" "standard" {
  display_name = "bigquery-test"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  standard {}
  environment {
    id = confluent_environment.bigquery-terraform.id
  }
}

//cria o tópico, que receberá os conectores
resource "confluent_kafka_topic" "bigquery-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "bigquery-topic"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.bigquery-app-manager-kafka-api-key.id
    secret = confluent_api_key.bigquery-app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "bigquery-sink" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "bigquery-sink"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.bigquery-app-manager-kafka-api-key.id
    secret = confluent_api_key.bigquery-app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "bigquery-source" {
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }
  topic_name    = "bigquery-source"
  rest_endpoint = confluent_kafka_cluster.standard.rest_endpoint
  credentials {
    key    = confluent_api_key.bigquery-app-manager-kafka-api-key.id
    secret = confluent_api_key.bigquery-app-manager-kafka-api-key.secret
  }
}



//essa api key serve para gerenciar o cluster criando tópicos, conectores e role bindings
resource "confluent_api_key" "bigquery-app-manager-kafka-api-key" {
  display_name = "bigquery-app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'bigquery-app-manager-admin' service account"
  owner {
    id          = confluent_service_account.bigquery-app-manager-admin.id
    api_version = confluent_service_account.bigquery-app-manager-admin.api_version
    kind        = confluent_service_account.bigquery-app-manager-admin.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.standard.id
    api_version = confluent_kafka_cluster.standard.api_version
    kind        = confluent_kafka_cluster.standard.kind

    environment {
      id = confluent_environment.bigquery-terraform.id
    }
  }
  //esse depends-on quer dizer que vai aguardar esse processo de role binding para prosseguir
  depends_on = [
    confluent_role_binding.bigquery-app-manager-admin
  ]
}

//aqui ele cria services accounts que servem para granularizar as permissões
resource "confluent_service_account" "bigquery-app-manager-admin" {
  display_name = "bigquery-app-manager-admin"
  description  = "Service account to manage 'bigquery-test' Kafka cluster"
}

resource "confluent_service_account" "bigquery-app-manager-sink" {
  display_name = "bigquery-app-manager-sink"
  description  = "Service account to manage 'bigquery-sink' Kafka topic"
}

resource "confluent_service_account" "bigquery-app-manager-source" {
  display_name = "bigquery-app-manager-source"
  description  = "Service account to manage 'bigquery-source' Kafka topic"
}


//aqui são as role bindings, que nada mais é que atribuição das permissões
resource "confluent_role_binding" "bigquery-app-manager-admin" {
  principal   = "User:${confluent_service_account.bigquery-app-manager-admin.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.standard.rbac_crn
}

resource "confluent_role_binding" "bigquery-sink-rb" {
  principal   = "User:${confluent_service_account.bigquery-app-manager-sink.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.bigquery-sink.topic_name}"
}

resource "confluent_role_binding" "bigquery-source-rb" {
  principal   = "User:${confluent_service_account.bigquery-app-manager-source.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/kafka=${confluent_kafka_cluster.standard.id}/topic=${confluent_kafka_topic.bigquery-source.topic_name}"
}

resource "confluent_role_binding" "connector-sink-rb" {
  principal   = "User:${confluent_service_account.bigquery-app-manager-sink.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/connector=${confluent_connector.sink.id}"
}

resource "confluent_role_binding" "connector-source-rb" {
  principal   = "User:${confluent_service_account.bigquery-app-manager-source.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${confluent_kafka_cluster.standard.rbac_crn}/connector=${confluent_connector.source.id}"
}

resource "confluent_connector" "source" {
  environment {
    id = confluent_environment.bigquery-terraform.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_0_TEST"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.bigquery-app-manager-admin.id
    "kafka.topic"              = confluent_kafka_topic.bigquery-topic.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }
}

resource "confluent_connector" "sink" {
  environment {
    id = confluent_environment.bigquery-terraform.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.standard.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"               = "DatagenSource"
    "name"                          = "DatagenSourceConnector_0_TEST"
    "kafka.auth.mode"               = "SERVICE_ACCOUNT"
    "kafka.service.account.id"      = confluent_service_account.bigquery-app-manager-admin.id
    "kafka.topic"                   = confluent_kafka_topic.bigquery-topic.topic_name
    "output.data.format"            = "JSON"
    "quickstart"                    = "ORDERS"
    "tasks.max"                     = "1"
    "topics"                        = confluent_kafka_topic.bigquery-sink.topic_name
    "schema.context.name"           = "default"
    "input.key.format"              = var.input_key_format
    "input.data.format"             = var.input_data_format
    "connector.class"               = "BigQuerySink"
    "name"                          = var.connector_name,
    "kafka.auth.mode"               = "SERVICE_ACCOUNT"
    "kafka.service.account.id"      = confluent_service_account.bigquery-app-manager-sink.id
    "keyfile"                       = var.gcp_keyfile
    "project"                       = var.gcp_proj_id
    "datasets"                      = var.gcp_dataset
    "partitioning.type"             = "INGESTION_TIME"
    "auto.create.tables"            = "true"
    "auto.update.schemas"           = "true"
    "sanitize.topics"               = "true"
    "sanitize.topics"               = "true"
    "sanitize.field.names"          = "false"
    "time.partitioning.type"        = "DAY"
    "allow.schema.unionization"     = "false"
    "all.bq.fields.nullable"        = "false"
    "convert.double.special.values" = "false"
    "max.poll.interval.ms"          = "300000"
    "max.poll.records"              = "500"
    "tasks.max"                     = "1"
  }
}

# resource "confluent_connector" "sink" {
#     for_each = { for k, v in var.gcs_connectors : k => v }
#     environment {
#       id = each.value.confluent_environment_id
#     }
#     kafka_cluster {
#       id = each.value.confluent_kafka_cluster
#     }

#     config_sensitive = {
#       "gcs.credentials.config" : each.value.varGcsCredentials,
#       "kafka.api.key" : each.value.kafka_api_key,
#       "kafka.api.secret" : each.value.kafka_api_secret
#     }

#     config_nonsensitive = {
#       "name" : each.value.varNomeConector,
#       "connector.class" : "GcsSink",
#       "kafka.auth.mode" : "KAFKA_API_KEY",
#       "topics" : each.value.varTopic,
#       "input.data.format" : each.value.varInputDataFormat,
#       "output.data.format" : each.value.varOutputDataFormat,
#       "gcs.bucket.name" : each.value.varGcsBucketName,
#       "time.interval" : each.value.varTimeInterval,
#       "flush.size" : each.value.varFlushSize,
#       "task.max" : each.value.varMaxTask
#     }

# }
