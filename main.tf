# AWS VPC and SUBNETS # TODO Handle optional VPC creation
/* module "aws" {
   source = "./modules/aws"
   region = var.aws.region
   number_of_public_subnets = var.aws.vpc.number_of_public_subnets
   number_of_private_subnets = var.aws.vpc.number_of_private_subnets
   prefix = var.aws.prefix
   owner = var.aws.owner
   instance = var.aws.instance
} */

 
data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  id = var.aws.vpc.id
}

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

# AWS TGW
/*
module "tgw" { 
   providers = {
      confluent = confluent.confluent_cloud
   }
   source = "./modules/tgw"
   count = upper(var.confluent_network.connection_type) == "TRANSITGATEWAY" ? 1 : 0
   prefix = var.aws.prefix
   owner = var.aws.owner
   region = var.aws.region
   vpc_id = data.aws_vpc.selected.id
   route_table_id = module.aws.route_table_id # TODO: Resolve this dependency
   environment = var.environment
   confluent_network_name = var.confluent_network.display_name
} */

# AWS PRIVATE LINK
module "plink" {
   providers = {
      confluent = confluent.confluent_cloud
   }
   source = "./modules/plink"
   count = upper(var.confluent_network.connection_type) == "PRIVATELINK" ? 1 : 0 
   region = var.aws.region
   vpc_id = data.aws_vpc.selected.id # Existing AWS VPC ID
   aws_account_id = var.aws.account_id # Existing AWS Account ID
   environment = var.environment
   confluent_network_name = var.confluent_network.display_name
}