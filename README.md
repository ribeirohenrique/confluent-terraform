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
```