# AWS Region
variable "region" {
  type = string
  default = "eu-east-1"
}

# AWS Prefix Tags
variable "prefix" {
 type = string
}

# AWS Owner Tag
variable "owner" {
 type = string
}

variable "vpc_id" {
    type = string
}

variable "route_table_id" {
    type = string
}

variable "routes" {
  description = "The AWS VPC CIDR blocks or subsets. List of destination routes for traffic from Confluent VPC to your VPC via Transit Gateway."
  type        = list(string)
  default     = [ "10.0.0.0/8"]
}

# Confluent Cloud Credentials  
# variable "confluent_cloud_api_key" {
#   type = string
 #  description = "Confluent Cloud API KEY. export TF_VAR_confluent_cloud_api_key=\"API_KEY\""
# }

# variable "confluent_cloud_api_secret" {
#   type = string
#    description = "Confluent Cloud API KEY. export TF_VAR_confluent_cloud_api_secret=\"API_SECRET\""
# }

variable "environment" {
    type = string
    default = "dev"
} 

variable "confluent_network_name" {
    type = string
    default = "confluent-network"
}
