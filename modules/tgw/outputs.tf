output "confluent_network" {
    value = confluent_network.tgw
}

output "confluent_transit_gateway_attachment" {
    value = confluent_transit_gateway_attachment.tgw
}

output "aws_transit_gateway" {
    value = aws_ec2_transit_gateway.tgw
}

output "aws_route" {
    value = aws_route.tgw
}
