### Observações (em construção)

#### Documentação
Veja [Sample Project for Confluent Terraform Provider](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/guides/sample-project) que demonstra um passo a passo de como executar este e outros exemplos.

#### Requisitos

- Service account criada e com as permissões necessárias para gerenciar as criações do script;
- [Confluent Cloud API Key](https://docs.confluent.io/cloud/current/access-management/authenticate/api-keys/api-keys.html#create-a-resource-api-key) para gerar os recursos;
- Criar um arquivo terraform.tfvars para armazenamento de variáveis de execução;

#### Exemplo de terraform.tfvars

```
confluent_cloud_api_key    = "xxxx"
confluent_cloud_api_secret = "xxxx"
organization_id            = "xxxx-xxxx-xxxx-xxxx-xxxx"
environment_id             = "env-xxxx"
cluster_id                 = "lkc-xxxx"
keyfile                    = {}
```

#### Exemplo alternativo de terraform.tfvars - v1

```
bigquery_connectors = {
"conector_1" = {
confluent_cloud_api_key    = "xxxx"
confluent_cloud_api_secret = "xxxx"
organization_id            = "xxxx-xxxx-xxxx-xxxx-xxxx"
environment_id             = "env-xxxx"
cluster_id                 = "lkc-xxxx"
keyfile                    = {}
  }
}
```

#### Exemplo alternativo de terraform.tfvars - v2


cloud_api_key       = "123"
cloud_api_secret    = "123"
kafka_rest_endpoint = "https://pkc-123.us-central1.gcp.confluent.cloud:443"
kafka_id            = "lkc-123"
topics = {
  "script_terraform_multiple_topics" = {
    partitions_count = "9"
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
  },
}


#### Exemplo alternativo de informar o provider externo ao main.tf criando um arquivo providers.tf

```
provider "confluent" {
  cloud_api_key = "123"
  cloud_api_secret = "123"
}
```