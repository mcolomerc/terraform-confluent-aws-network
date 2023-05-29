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

output "transit_gateway" {
  value = module.tgw[0].aws_transit_gateway
}

output "transit_gateay_confluent_network" {
  value = module.tgw[0].confluent_network
}

output "transit_gateay_route" {
  value = module.tgw[0].aws_route
}

 