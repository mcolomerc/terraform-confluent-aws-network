terraform {
  required_version = ">= 1.3"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">=1.51.0"
      configuration_aliases = [ confluent.confluent_cloud ]
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1" 
    } 
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    } 
  }
}
