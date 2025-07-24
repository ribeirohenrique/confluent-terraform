terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
    }
  }
}

resource "confluent_environment" "create_environment" {
  for_each = var.environments
  display_name = each.value.display_name

  stream_governance {
    package = each.value.stream_governance
  }

  lifecycle {
    prevent_destroy = false
  }
}
