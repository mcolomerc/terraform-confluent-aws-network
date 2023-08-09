## Data Sources
# -----------------------------------------------------------
# Confluent Cloud Environment 
data "confluent_environment" "main" {
  id = var.environment
}

# AWS Availability Zones
data "aws_availability_zones" "available" {}

# AWS VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# AWS Subnets query
data "aws_subnets" "selected" {
  filter {
     name   = "vpc-id"
     values = [data.aws_vpc.selected.id]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = [true]
  }
} 
# -----------------------------------------------------------
## Resources
resource "confluent_network" "aws-private-link" {
  display_name     = var.confluent_network_name
  cloud            = "AWS"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones           = slice(data.aws_availability_zones.available.zone_ids, 0, 3)
  dns_config {
    resolution = "PRIVATE"
  }
  environment {
    id = data.confluent_environment.main.id
  }

  // lifecycle {
  //  prevent_destroy = true
  // }
}

resource "confluent_private_link_access" "aws" {
  display_name = "${var.confluent_network_name} Access"
  aws {
    account = var.aws_account_id
  }
  environment {
    id = data.confluent_environment.main.id
  }
  network {
    id = confluent_network.aws-private-link.id
  }
  // lifecycle {
       // prevent_destroy = true
  // }
}
