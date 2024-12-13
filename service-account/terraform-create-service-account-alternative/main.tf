terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.7.0"
    }
  }
}

resource "confluent_service_account" "service_account" {
  for_each     = { for k, v in var.service_accounts : k => v if v.description != null}
  display_name = each.value.name
  description  = each.value.description
}

resource "confluent_role_binding" "service_account_binding" {
  for_each    = { for k, v in var.service_accounts : k => v if v.role != null }
  principal   = "User:${each.value.name}"
  role_name   = each.value.role
  crn_pattern = each.value.crn_pattern
}