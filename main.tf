# AWS VPC and SUBNETS
module "aws" {
   source = "./modules/aws"
   region = var.aws.region
   number_of_public_subnets = var.aws.vpc.number_of_public_subnets
   number_of_private_subnets = var.aws.vpc.number_of_private_subnets
   prefix = var.aws.prefix
   owner = var.aws.owner
   instance = var.aws.instance
}

# AWS TGW
module "tgw" { 
   providers = {
      confluent = confluent.confluent_cloud
   }
   source = "./modules/tgw"
   count = upper(var.confluent_network.connection_type) == "TRANSITGATEWAY" ? 1 : 0
   prefix = var.aws.prefix
   owner = var.aws.owner
   region = var.aws.region
   vpc_id = module.aws.vpc.id
   route_table_id = module.aws.route_table_id 
   environment = var.environment
   confluent_network_name = var.confluent_network.display_name
}