terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_kafka_cluster" "east" {
  id = var.east_kafka_cluster_id
  environment {
    id = var.east_kafka_cluster_environment_id
  }
}

resource "confluent_service_account" "app-manager-east-cluster" {
  display_name = "app-manager-east-cluster"
  description  = "Service account to manage source Kafka cluster"
}

// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "app-manager-east-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager-east-cluster.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.east.rbac_crn
}

resource "confluent_api_key" "app-manager-east-cluster-api-key" {
  display_name = "app-manager-east-cluster-api-key"
  description  = "Kafka API Key that is owned by 'app-manager-east-cluster' service account"
  owner {
    id          = confluent_service_account.app-manager-east-cluster.id
    api_version = confluent_service_account.app-manager-east-cluster.api_version
    kind        = confluent_service_account.app-manager-east-cluster.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.east.id
    api_version = data.confluent_kafka_cluster.east.api_version
    kind        = data.confluent_kafka_cluster.east.kind

    environment {
      id = data.confluent_kafka_cluster.east.environment.0.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-east-cluster-admin is created before
  # confluent_api_key.app-manager-east-cluster-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-east-cluster-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-east-cluster-admin
  ]
}

data "confluent_kafka_cluster" "west" {
  id = var.west_kafka_cluster_id
  environment {
    id = var.west_kafka_cluster_environment_id
  }
}

resource "confluent_service_account" "app-manager-west-cluster" {
  display_name = "app-manager-west-cluster"
  description  = "Service account to manage destination Kafka cluster"
}

// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "app-manager-west-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager-west-cluster.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.west.rbac_crn
}

resource "confluent_api_key" "app-manager-west-cluster-api-key" {
  display_name = "app-manager-west-cluster-api-key"
  description  = "Kafka API Key that is owned by 'app-manager-west-cluster' service account"
  owner {
    id          = confluent_service_account.app-manager-west-cluster.id
    api_version = confluent_service_account.app-manager-west-cluster.api_version
    kind        = confluent_service_account.app-manager-west-cluster.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.west.id
    api_version = data.confluent_kafka_cluster.west.api_version
    kind        = data.confluent_kafka_cluster.west.kind

    environment {
      id = data.confluent_kafka_cluster.west.environment.0.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-west-cluster-admin is created before
  # confluent_api_key.app-manager-west-cluster-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-west-cluster-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-west-cluster-admin
  ]
}

// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/cluster-links-cc.html#create-a-cluster-link-in-bidirectional-mode
resource "confluent_cluster_link" "east-to-west" {
  link_name = var.cluster_link_name
  link_mode = "BIDIRECTIONAL"
  local_kafka_cluster {
    id            = data.confluent_kafka_cluster.east.id
    rest_endpoint = data.confluent_kafka_cluster.east.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-east-cluster-api-key.id
      secret = confluent_api_key.app-manager-east-cluster-api-key.secret
    }
  }

  remote_kafka_cluster {
    id                 = data.confluent_kafka_cluster.west.id
    bootstrap_endpoint = data.confluent_kafka_cluster.west.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.app-manager-west-cluster-api-key.id
      secret = confluent_api_key.app-manager-west-cluster-api-key.secret
    }
  }
}

//Cria um tópico para gravar mensagens EAST
resource "confluent_kafka_topic" "confluent_topic_east" {
  kafka_cluster {
    id = var.east_kafka_cluster_id
  }

  topic_name       = var.east_topic_name
  rest_endpoint    = data.confluent_kafka_cluster.east.rest_endpoint
  partitions_count = 2
  config = {
    "cleanup.policy"      = "delete"
    "delete.retention.ms" = "3600000"
    ##"max.compaction.lag.ms"               = "9223372036854775807"
    ##"max.message.bytes"                   = "2097164"
    ##"message.timestamp.difference.max.ms" = "9223372036854775807"
    ##"message.timestamp.type"              = "CreateTime"
    ##"min.compaction.lag.ms"               = "0"
    ##"min.insync.replicas"                 = "2"
    "retention.bytes" = "104857600"
    "retention.ms"    = "86400000"
    "segment.bytes"   = "52428800"
    "segment.ms"      = "86400000"
  }
  credentials {
    key    = confluent_api_key.app-manager-east-cluster-api-key.id
    secret = confluent_api_key.app-manager-east-cluster-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_mirror_topic" "from-east" {
  source_kafka_topic {
    topic_name = var.east_topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.east-to-west.link_name
  }
  kafka_cluster {
    id            = data.confluent_kafka_cluster.west.id
    rest_endpoint = data.confluent_kafka_cluster.west.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-west-cluster-api-key.id
      secret = confluent_api_key.app-manager-west-cluster-api-key.secret
    }
  }

  depends_on = [
    confluent_cluster_link.east-to-west,
    confluent_cluster_link.west-to-east,
    confluent_kafka_acl.app_producer_read_on_target_topic_east
  ]
}

resource "confluent_cluster_link" "west-to-east" {
  link_name = var.cluster_link_name
  link_mode = "BIDIRECTIONAL"
  local_kafka_cluster {
    id            = data.confluent_kafka_cluster.west.id
    rest_endpoint = data.confluent_kafka_cluster.west.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-west-cluster-api-key.id
      secret = confluent_api_key.app-manager-west-cluster-api-key.secret
    }
  }

  remote_kafka_cluster {
    id                 = data.confluent_kafka_cluster.east.id
    bootstrap_endpoint = data.confluent_kafka_cluster.east.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.app-manager-east-cluster-api-key.id
      secret = confluent_api_key.app-manager-east-cluster-api-key.secret
    }
  }
}

//Cria um tópico para gravar mensagens WEST
resource "confluent_kafka_topic" "confluent_topic_west" {
  kafka_cluster {
    id = var.west_kafka_cluster_id
  }

  topic_name       = var.west_topic_name
  rest_endpoint    = data.confluent_kafka_cluster.west.rest_endpoint
  partitions_count = 2
  config = {
    "cleanup.policy"      = "delete"
    "delete.retention.ms" = "3600000"
    ##"max.compaction.lag.ms"               = "9223372036854775807"
    ##"max.message.bytes"                   = "2097164"
    ##"message.timestamp.difference.max.ms" = "9223372036854775807"
    ##"message.timestamp.type"              = "CreateTime"
    ##"min.compaction.lag.ms"               = "0"
    ##"min.insync.replicas"                 = "2"
    "retention.bytes" = "104857600"
    "retention.ms"    = "86400000"
    "segment.bytes"   = "52428800"
    "segment.ms"      = "86400000"
  }
  credentials {
    key    = confluent_api_key.app-manager-west-cluster-api-key.id
    secret = confluent_api_key.app-manager-west-cluster-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "app_producer_read_on_target_topic_east" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.east.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.confluent_topic_east.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager-east-cluster.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.east.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-east-cluster-api-key.id
    secret = confluent_api_key.app-manager-east-cluster-api-key.secret
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "app_producer_read_on_target_topic_west" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.west.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.confluent_topic_west.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-manager-west-cluster.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.west.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-west-cluster-api-key.id
    secret = confluent_api_key.app-manager-west-cluster-api-key.secret
  }
}

resource "confluent_kafka_mirror_topic" "from-west" {
  source_kafka_topic {
    topic_name = var.west_topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.west-to-east.link_name
  }
  kafka_cluster {
    id            = data.confluent_kafka_cluster.east.id
    rest_endpoint = data.confluent_kafka_cluster.east.rest_endpoint
    credentials {
      key    = confluent_api_key.app-manager-east-cluster-api-key.id
      secret = confluent_api_key.app-manager-east-cluster-api-key.secret
    }
  }

  depends_on = [
    confluent_cluster_link.east-to-west,
    confluent_cluster_link.west-to-east,
    confluent_kafka_acl.app_producer_read_on_target_topic_west
  ]
}
