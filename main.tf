# AWS VPC and SUBNETS # TODO Handle optional VPC creation
# Create AWS VPC and Subnets if aws.vpc_id is not provided 
module "aws_vpc" {
   source = "./modules/aws_vpc"
   vpc_id = var.aws.vpc.id # Existing AWS VPC ID
   region = var.aws.region
   number_of_public_subnets = var.aws.vpc.number_of_public_subnets
   number_of_private_subnets = var.aws.vpc.number_of_private_subnets
   prefix = var.aws.prefix
   owner = var.aws.owner 
} 

## AWS EC2 Instance Bastion Host
# Create AWS EC2 Instance if aws.instance is provided
module "aws_bastion" {
   source = "./modules/aws_bastion" 
   count = var.aws.instance != null ? 1 : 0
   instance = var.aws.instance 
   vpc_id = can(var.aws.vpc.id) ? var.aws.vpc.id : module.aws_vpc.vpc.id # Existing AWS VPC ID
   prefix = var.aws.prefix
   owner = var.aws.owner 
}

# CONFLUENT - AWS PRIVATE LINK
# Create Confluent Network and Private Link Access if confluent_network.connection_type is PRIVATELINK
module "plink" {
   providers = {
      confluent = confluent.confluent_cloud
   }
   source = "./modules/plink"
   count = upper(var.confluent_network.connection_type) == "PRIVATELINK" ? 1 : 0 
   region = var.aws.region
   vpc_id = can(var.aws.vpc.id) ? var.aws.vpc.id : module.aws_vpc.vpc.id # Existing AWS VPC ID
   aws_account_id = var.aws.account_id # Existing AWS Account ID
   environment = var.environment
   confluent_network_name = var.confluent_network.display_name
   prefix = var.aws.prefix
   owner = var.aws.owner
}

# CONFLUENT - AWS TGW
module "tgw" { 
   providers = {
      confluent = confluent.confluent_cloud
   }
   source = "./modules/tgw"
   count = upper(var.confluent_network.connection_type) == "TRANSITGATEWAY" ? 1 : 0
   prefix = var.aws.prefix
   owner = var.aws.owner
   region = var.aws.region
   vpc_id = can(var.aws.vpc.id) ? var.aws.vpc.id : module.aws_vpc.vpc.id
   route_table_id = module.aws_vpc.route_table.id # TODO: Resolve this dependency
   environment = var.environment
   confluent_network_name = var.confluent_network.display_name
} 

