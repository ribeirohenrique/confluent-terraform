output "confluent_environments_map" {
  value = { for k, env in confluent_environment.create_environment :
    k => {
      id            = env.id
      display_name  = env.display_name
      resource_name = env.resource_name
    }
  }
}