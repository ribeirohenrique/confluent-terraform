terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

data "confluent_kafka_cluster" "source" {
  id = var.source_kafka_cluster_id
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_environment" "environment" {
  id = var.environment_id
}

data "confluent_service_account" "source_service_account" {
  id = var.source_service_account
}

// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "source_service_account_rb" {
  principal   = "User:${var.source_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.source.rbac_crn
}

resource "confluent_api_key" "source_service_account_api_key" {
  display_name = "source_service_account_api_key"
  description  = "Kafka API Key that is owned by ${data.confluent_service_account.source_service_account.display_name} service account"
  owner {
    id          = data.confluent_service_account.source_service_account.id
    api_version = data.confluent_service_account.source_service_account.api_version
    kind        = data.confluent_service_account.source_service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.source.id
    api_version = data.confluent_kafka_cluster.source.api_version
    kind        = data.confluent_kafka_cluster.source.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-east-cluster-admin is created before
  # confluent_api_key.app-manager-east-cluster-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-east-cluster-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.source_service_account_rb
  ]
}


//segunda parte
data "confluent_kafka_cluster" "destination" {
  id = var.destination_kafka_cluster_id
  environment {
    id = data.confluent_environment.environment.id
  }
}

data "confluent_service_account" "destination_service_account" {
  id = var.destination_service_account
}

// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "destination_service_account_rb" {
  principal   = "User:${var.destination_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.destination.rbac_crn
}

resource "confluent_api_key" "destination_service_account_api_key" {
  display_name = "destination_service_account_api_key"
  description  = "Kafka API Key that is owned by ${data.confluent_service_account.destination_service_account.display_name} service account"
  owner {
    id          = data.confluent_service_account.destination_service_account.id
    api_version = data.confluent_service_account.destination_service_account.api_version
    kind        = data.confluent_service_account.destination_service_account.kind
  }

  managed_resource {
    id          = data.confluent_kafka_cluster.destination.id
    api_version = data.confluent_kafka_cluster.destination.api_version
    kind        = data.confluent_kafka_cluster.destination.kind

    environment {
      id = data.confluent_environment.environment.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-west-cluster-admin is created before
  # confluent_api_key.app-manager-west-cluster-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-west-cluster-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.destination_service_account_rb
  ]
}

// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/cluster-links-cc.html#create-a-cluster-link-in-bidirectional-mode
resource "confluent_cluster_link" "source_to_destination" {
  link_name = var.cluster_link_name
  link_mode = "BIDIRECTIONAL"
  local_kafka_cluster {
    id            = data.confluent_kafka_cluster.source.id
    rest_endpoint = data.confluent_kafka_cluster.source.rest_endpoint
    credentials {
      key    = confluent_api_key.source_service_account_api_key.id
      secret = confluent_api_key.source_service_account_api_key.secret
    }
  }

  remote_kafka_cluster {
    id                 = data.confluent_kafka_cluster.destination.id
    bootstrap_endpoint = data.confluent_kafka_cluster.destination.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_api_key.source_service_account_api_key,
    confluent_kafka_acl.service_account_acl_source_describe,
    confluent_kafka_acl.service_account_acl_source_read,
    confluent_kafka_acl.service_account_acl_source_describe_configs,
    confluent_role_binding.source_service_account_rb
  ]
}

//Agora virão os mirror topics
resource "confluent_kafka_mirror_topic" "mirror_topic_source" {
  source_kafka_topic {
    topic_name = var.source_topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.source_to_destination.link_name
  }
  kafka_cluster {
    id            = data.confluent_kafka_cluster.destination.id
    rest_endpoint = data.confluent_kafka_cluster.destination.rest_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_cluster_link.source_to_destination,
    confluent_cluster_link.destination_to_source,
    confluent_kafka_acl.service_account_acl_source_describe,
    confluent_kafka_acl.service_account_acl_source_read,
    confluent_kafka_acl.service_account_acl_source_describe_configs
  ]
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_source_read" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.source.id
  }
  resource_type = "TOPIC"
  resource_name = var.source_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${var.source_service_account}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.source.rest_endpoint
  credentials {
    key    = confluent_api_key.source_service_account_api_key.id
    secret = confluent_api_key.source_service_account_api_key.secret
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_source_describe_configs" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.source.id
  }
  resource_type = "TOPIC"
  resource_name = var.source_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${var.source_service_account}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.source.rest_endpoint
  credentials {
    key    = confluent_api_key.source_service_account_api_key.id
    secret = confluent_api_key.source_service_account_api_key.secret
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_source_describe" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.source.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${var.source_service_account}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.source.rest_endpoint
  credentials {
    key    = confluent_api_key.source_service_account_api_key.id
    secret = confluent_api_key.source_service_account_api_key.secret
  }
}

resource "confluent_cluster_link" "destination_to_source" {
  link_name = var.cluster_link_name
  link_mode = "BIDIRECTIONAL"
  local_kafka_cluster {
    id            = data.confluent_kafka_cluster.destination.id
    rest_endpoint = data.confluent_kafka_cluster.destination.rest_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }

  remote_kafka_cluster {
    id                 = data.confluent_kafka_cluster.source.id
    bootstrap_endpoint = data.confluent_kafka_cluster.source.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.source_service_account_api_key.id
      secret = confluent_api_key.source_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_api_key.destination_service_account_api_key,
    confluent_kafka_acl.service_account_acl_destination_describe,
    confluent_kafka_acl.service_account_acl_destination_read,
    confluent_kafka_acl.service_account_acl_destination_describe_configs,
    confluent_role_binding.destination_service_account_rb
  ]
}

resource "confluent_kafka_mirror_topic" "mirror_topic_destination" {
  source_kafka_topic {
    topic_name = var.destionation_topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.destination_to_source.link_name
  }
  kafka_cluster {
    id            = data.confluent_kafka_cluster.source.id
    rest_endpoint = data.confluent_kafka_cluster.source.rest_endpoint
    credentials {
      key    = confluent_api_key.source_service_account_api_key.id
      secret = confluent_api_key.source_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_cluster_link.source_to_destination,
    confluent_cluster_link.destination_to_source,
    confluent_kafka_acl.service_account_acl_destination_describe,
    confluent_kafka_acl.service_account_acl_destination_read,
    confluent_kafka_acl.service_account_acl_destination_describe_configs,
  ]
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_destination_read" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.destination.id
  }
  resource_type = "TOPIC"
  resource_name = var.destionation_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${var.destination_service_account}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.destination.rest_endpoint
  credentials {
    key    = confluent_api_key.destination_service_account_api_key.id
    secret = confluent_api_key.destination_service_account_api_key.secret
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_destination_describe_configs" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.destination.id
  }
  resource_type = "TOPIC"
  resource_name = var.destionation_topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${var.destination_service_account}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.destination.rest_endpoint
  credentials {
    key    = confluent_api_key.destination_service_account_api_key.id
    secret = confluent_api_key.destination_service_account_api_key.secret
  }
}

//Atribui a Service account criada acima a Role ACL de READ ao tópico
resource "confluent_kafka_acl" "service_account_acl_destination_describe" {
  kafka_cluster {
    id = data.confluent_kafka_cluster.destination.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${var.destination_service_account}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = data.confluent_kafka_cluster.destination.rest_endpoint
  credentials {
    key    = confluent_api_key.destination_service_account_api_key.id
    secret = confluent_api_key.destination_service_account_api_key.secret
  }
}