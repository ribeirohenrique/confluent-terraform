terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"

    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//Cluster source
data "confluent_environment" "source_environment" {
  id = var.source_environment_id
}

data "confluent_kafka_cluster" "source_cluster" {
  id = var.source_kafka_cluster_id
  environment {
    id = data.confluent_environment.source_environment.id
  }
}

data "confluent_service_account" "source_service_account" {
  id = var.source_service_account
}

//Cluster destination
data "confluent_environment" "destination_environment" {
  id = var.destination_environment_id
}

data "confluent_kafka_cluster" "destination_cluster" {
  id = var.destination_kafka_cluster_id
  environment {
    id = data.confluent_environment.destination_environment.id
  }
}

data "confluent_service_account" "destination_service_account" {
  id = var.destination_service_account
}

// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "source_service_account_rb" {
  principal   = "User:${var.source_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.source_cluster.rbac_crn
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
    id          = data.confluent_kafka_cluster.source_cluster.id
    api_version = data.confluent_kafka_cluster.source_cluster.api_version
    kind        = data.confluent_kafka_cluster.source_cluster.kind

    environment {
      id = data.confluent_environment.source_environment.id
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


// See
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#rbac-roles-and-kafka-acls-summary
// and
// https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/security-cloud.html#ccloud-rbac-roles for more details.
resource "confluent_role_binding" "destination_service_account_rb" {
  principal   = "User:${var.destination_service_account}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = data.confluent_kafka_cluster.destination_cluster.rbac_crn
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
    id          = data.confluent_kafka_cluster.destination_cluster.id
    api_version = data.confluent_kafka_cluster.destination_cluster.api_version
    kind        = data.confluent_kafka_cluster.destination_cluster.kind

    environment {
      id = data.confluent_environment.destination_environment.id
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
  link_mode = "DESTINATION"
  config = {
    "acl.sync.enable" : "true",
    "acl.sync.ms" : "5000",
    "auto.create.mirror.topics.enable" : "true",
    "topic.config.sync.ms" : "5000"
    "consumer.offset.sync.enable" : "true"
  }
  source_kafka_cluster {
    id                 = data.confluent_kafka_cluster.source_cluster.id
    bootstrap_endpoint = data.confluent_kafka_cluster.source_cluster.bootstrap_endpoint
    credentials {
      key    = confluent_api_key.source_service_account_api_key.id
      secret = confluent_api_key.source_service_account_api_key.secret
    }
  }

  destination_kafka_cluster {
    id            = data.confluent_kafka_cluster.destination_cluster.id
    rest_endpoint = data.confluent_kafka_cluster.destination_cluster.rest_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_api_key.source_service_account_api_key,
    confluent_role_binding.source_service_account_rb
  ]
}

//Agora virão os mirror topics
resource "confluent_kafka_mirror_topic" "mirror_topic_source" {
  count = var.create_mirror_topic ? 1 : 0
  source_kafka_topic {
    topic_name = var.source_topic_name
  }
  cluster_link {
    link_name = confluent_cluster_link.source_to_destination.link_name
  }
  kafka_cluster {
    id            = data.confluent_kafka_cluster.destination_cluster.id
    rest_endpoint = data.confluent_kafka_cluster.destination_cluster.rest_endpoint
    credentials {
      key    = confluent_api_key.destination_service_account_api_key.id
      secret = confluent_api_key.destination_service_account_api_key.secret
    }
  }

  depends_on = [
    confluent_cluster_link.source_to_destination
  ]
}