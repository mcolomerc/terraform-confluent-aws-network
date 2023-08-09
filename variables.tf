# AWS
 variable "aws" {
  type = object({
    region = string
    prefix = string
    owner = string
    vpc = object({
      id = optional(string) # TODO: If not provided, create a new VPC
      number_of_public_subnets = optional(number)
      number_of_private_subnets = optional(number) 
    })
    instance = optional(object({ # TODO: If provided, create a new EC2 Instance
        name = string
        type = string 
    }))
    account_id = optional(string) # TODO: Required for Private Link
  }) 
}  

# Confluent Cloud Credentials  
variable "confluent_cloud_api_key" {
  type = string
  description = "Confluent Cloud API KEY. export TF_VAR_confluent_cloud_api_key=\"API_KEY\""
}

variable "confluent_cloud_api_secret" {
  type = string
   description = "Confluent Cloud API KEY. export TF_VAR_confluent_cloud_api_secret=\"API_SECRET\""
}

# Confluent Environment
variable "environment" {
  type = string
  default = "dev"
}

# Confluent Network
variable "confluent_network" {
  type = object({
    display_name = string  
    connection_type = string
    cidr = optional(string)
    zones = optional(list(string))
    dns = optional(string)
  })
  validation {
    condition = (
      contains(["PEERING", "TRANSITGATEWAY", "PRIVATELINK"], var.confluent_network.connection_type)  
      && (var.confluent_network.connection_type == "PEERING" ? var.confluent_network.connection_type == "TRANSITGATEWAY" && var.confluent_network.cidr != null : true) 
     )
    error_message = <<EOT
- network.connection_type => PEERING or TRANSITGATEWAY or PRIVATELINK  
- network.cidr => RFC 1918 private address spaces: 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
RFC 6598 private address space: 100.64.0.0/10
RFC 2544 private address space: 198.18.0.0/15
    EOT
  }
}
 