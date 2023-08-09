
 

variable "environment" {
    type = string
    default = "dev"
}

variable "confluent_network_name" {
    type = string
    default = "confluent-network"
}

# AWS Region
variable "region" {
  type = string
  default = "eu-east-1"
}

# AWS VPC_ID
variable "vpc_id" {
  description = "The AWS VPC ID"
  type        = string
}

# AWS ACCOUNT ID
variable "aws_account_id" {
  description = "The AWS Account ID (12 digits)"
  type        = string
}
 