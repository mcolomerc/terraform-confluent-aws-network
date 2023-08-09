# AWS 
/* 
output "vpc" {
  value = module.aws.vpc
}

output "public_subnets" {
  value = module.aws.public_subnets
}

output "private_subnets" {
  value = module.aws.private_subnets
}

output "bastion" {
  value = module.aws.bastion
}

# TGW
output "transit_gateway" {
  value = length(module.tgw) > 0 ? module.tgw[0].aws_transit_gateway : null   
}

output "transit_gateway_confluent_network" {
  value = length(module.tgw) > 0 ? module.tgw[0].confluent_network : null   
}

output "transit_gateay_confluent_network" {
  value = length(module.tgw) > 0 ? module.tgw[0].confluent_network : null   
}

output "transit_gateay_route" {
  value = length(module.tgw) > 0 ? module.tgw[0].aws_route : null
}
*/

# Private LINK
output "private_link_confluent_network" {
  value = length(module.plink) > 0 ? module.plink[0].confluent_network : null
}

output "confluent_private_link" {
  value = length(module.plink) > 0 ? module.plink[0].confluent_private_link : null
}