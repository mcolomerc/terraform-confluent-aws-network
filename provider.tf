terraform {
  required_version = ">= 1.3"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.42.0"
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

provider "aws" { 
    region = "${var.aws.region}"
}

provider "confluent" {  
  alias = "confluent_cloud"
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}
