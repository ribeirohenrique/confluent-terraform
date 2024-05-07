output "service_accounts" {
  description = "Information about all service accounts"
  value = { for k, b in confluent_service_account.service_account : k => {
    display_name = b.display_name
    description  = b.description
    id           = b.id
    }
  }
}

output "service_account_bindings" {
  description = "Information about all service accounts bindings"
  value = { for k, b in confluent_role_binding.service_account_binding : k => {
    principal   = b.principal
    role_name   = b.role_name
    crn_pattern = b.crn_pattern
    }
  }
}
