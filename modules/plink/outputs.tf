output "confluent_network" {
    value = confluent_network.aws-private-link
}

output "confluent_private_link" {
    value = confluent_private_link_access.aws
}

output "vpc" {
    value = data.aws_vpc.selected
}

output "public_subnets" {
    value = data.aws_subnets.selected
}
 
output "availability_zone" {
    value = local.availability_zone_subnets
}

output "aws_route53_zone" {
    value = aws_route53_zone.privatelink
}

output "aws_route53_records" {
    value = aws_route53_record.privatelink
}