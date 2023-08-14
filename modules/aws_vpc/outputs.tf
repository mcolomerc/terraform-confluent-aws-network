output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnets" {
  value = aws_subnet.vpc_public_subnet
}

output "private_subnets" {
  value = aws_subnet.vpc_private_subnet
}

output "internet_gateway" {
  value = aws_internet_gateway.vpc_internet_gateway
}

output "route_table" {
  value = aws_route_table.vpc_route_table
}