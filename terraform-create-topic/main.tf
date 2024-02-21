terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.61.0"
    }
  }
}

//Define a Cloud API Key criada anteriormente
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//Define o Cluster a ser utilizado
data "confluent_kafka_cluster" "confluent_cluster" {
  id = var.cluster_id
  environment {
    id = var.environment_id
  }
}

//Cria um tópico para gravar mensagens
resource "confluent_kafka_topic" "confluent_topic" {
  kafka_cluster {
    id = var.cluster_id
  }

  topic_name       = var.topic_name
  rest_endpoint    = data.confluent_kafka_cluster.confluent_cluster.rest_endpoint
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
    key    = var.service_account_cluster_key
    secret = var.service_account_cluster_secret
  }

  lifecycle {
    prevent_destroy = true
  }
}


##https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html

/*
delete.retention.ms
The amount of time to retain delete tombstone markers for log compacted topics.
This setting also gives a bound on the time in which a consumer must complete
a read if they begin from offset 0 to ensure that they get a valid snapshot of the final stage
(otherwise delete tombstones may be collected before they complete their scan).
*/

/*
retention.bytes
This configuration controls the maximum size
a partition (which consists of log segments)
can grow to before we will discard old log segments
to free up space if we are using the “delete” retention policy.
By default there is no size limit only a time limit.
Since this limit is enforced at the partition level,
multiply it by the number of partitions to compute the topic retention in bytes.
*/

/*
retention.ms
This configuration controls the maximum time we will retain
a log before we will discard old log segments to free up space
if we are using the “delete” retention policy. This represents an SLA
on how soon consumers must read their data. If set to -1, no time limit is applied.
*/

/*
segment.bytes
This configuration controls the segment file size for the log.
Retention and cleaning is always done a file at a time so a larger
segment size means fewer files but less granular control over retention.
*/

/*
segment.ms
This configuration controls the period of time after which Kafka
will force the log to roll even if the segment file isn’t full
to ensure that retention can delete or compact old data.
*/
