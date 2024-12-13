variable "schema_registry_id" {
  description = "Schema registry Id"
  type        = string
  sensitive   = false
}

variable "schema_registry_rest_endpoint" {
  description = "Schema registry endpoint"
  type        = string
  sensitive   = false
}

variable "schema_registry_api_key" {
  description = "Schema registry API Key"
  type        = string
  sensitive   = true
}

variable "schema_registry_api_secret" {
  description = "Schema registry API Secret"
  type        = string
  sensitive   = true
}

variable "subject_name" {
  description = "Subject Name"
  type        = string
  sensitive   = false
}

variable "compatibility_level" {
  description = "Compatibility Level"
  type        = string
  sensitive   = false

  validation {
    condition     = contains(["BACKWARD", "BACKWARD_TRANSITIVE", "FORWARD", "FORWARD_TRANSITIVE", "FULL", "FULL_TRANSITIVE", "NONE"], var.compatibility_level)
    error_message = "The compatibility_level must be either 'BACKWARD', 'BACKWARD_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'FULL', 'FULL_TRANSITIVE', 'NONE'."
  }
}