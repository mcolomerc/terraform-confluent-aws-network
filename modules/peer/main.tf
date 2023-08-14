## Data Sources
# -----------------------------------------------------------
# Confluent Cloud Environment 
data "confluent_environment" "main" {
  id = var.environment
}


resource "confluent_network" "peering" {
  display_name     = "Peering Network"
  cloud            = "AWS"
  region           = var.region
  cidr             = var.cidr
  connection_types = ["PEERING"]
  environment {
    id = data.confluent_environment.main.id
  }
}

resource "confluent_peering" "aws" {
  display_name = "AWS Peering"
  aws {
    account         = var.aws_account_id
    vpc             = var.vpc_id
    routes          = var.routes
    customer_region = var.customer_region
  }
  environment {
    id = data.confluent_environment.main.id
  }
  network {
    id = confluent_network.peering.id
  }
}

# Accepter's side of the connection.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_peering_connection
data "aws_vpc_peering_connection" "accepter" {
  vpc_id      = confluent_network.peering.aws[0].vpc
  peer_vpc_id = confluent_peering.aws.aws[0].vpc
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = data.aws_vpc_peering_connection.accepter.id
  auto_accept               = true
}

# Find the routing table
data "aws_route_tables" "rts" {
  vpc_id = var.vpc_id
}

resource "aws_route" "r" {
  for_each                  = toset(data.aws_route_tables.rts.ids)
  route_table_id            = each.key
  destination_cidr_block    = confluent_network.peering.cidr
  vpc_peering_connection_id = data.aws_vpc_peering_connection.accepter.id
}