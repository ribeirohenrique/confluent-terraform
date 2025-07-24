variable "environments" {
  description = "Environment variables for tfvars file"
  type = map(object({
    display_name : string
    stream_governance : string
    confluent_cloud_api_key : string
    confluent_cloud_api_secret : string
  }))
  default = {}
}