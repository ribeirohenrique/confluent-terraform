# Variable for the above module
variable "service_accounts" {
  description = "Service Accounts variables for tfvars file"
  type = map(object({
    confluent_cloud_api_key    = string
    confluent_cloud_api_secret = string
    name                       = string
    description                = optional(string)
    role                       = optional(string)
    crn_pattern                = optional(string)
  }))
}
