locals {
  coffee_varieties = {
    "bourbon" = {}
    "typica" = {}
    "caturra" = {}
    "catuai" = {}
    "geisha" = {}
    "maragogipe" = {}
    "sl28" = {}
    "sl34" = {}
    "pacamara" = {}
    "mundo-novo" = {}
  }

  default_topic_config = {
    partitions_count = "1"
    config = {
      "cleanup.policy"                      = "delete"
      "delete.retention.ms"                 = "86400000"
      "max.compaction.lag.ms"               = "9223372036854775807"
      "max.message.bytes"                   = "2097164"
      "message.timestamp.after.max.ms"      = "9223372036854775807"
      "message.timestamp.before.max.ms"     = "9223372036854775807"
      "message.timestamp.difference.max.ms" = "9223372036854775807"
      "message.timestamp.type"              = "CreateTime"
      "min.compaction.lag.ms"               = "0"
      "min.insync.replicas"                 = "2"
      "retention.bytes"                     = "-1"
      "retention.ms"                        = "604800000"
      "segment.bytes"                       = "104857600"
      "segment.ms"                          = "604800000"
    }
  }
}