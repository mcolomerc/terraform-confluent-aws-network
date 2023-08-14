# Use data sources allow configuration to be
# generic for any region
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# Crate a AWS VPC which contains the following
#   - VPC
#   - Public subnet(s)
#   - Private subnet(s)
#   - Internet Gateway
#   - Routing table

resource "aws_vpc" "vpc" {
  count = var.vpc_id == null ? 1 : 0
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name
 
  tags = {
    Name = "${var.prefix}-vpc"
    Owner = var.owner
  }
}

locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : aws_vpc.vpc[0].id
}

resource "aws_subnet" "vpc_public_subnet" {
  # Number of public subnet is defined in vars
  count = var.number_of_public_subnets

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + var.number_of_private_subnets}.0/24"
  vpc_id                  = aws_vpc.vpc[0].id
  map_public_ip_on_launch = true # This makes the subnet public

  tags = {
    Name = "${var.prefix}-public-subnet-${count.index}"
    Owner = var.owner
  }
}

resource "aws_subnet" "vpc_private_subnet" {
  # Number of private subnet is defined in vars
  count = var.number_of_private_subnets

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vpc[0].id

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  count = var.vpc_id == null ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.prefix}-internet-gateway"
    Owner = var.owner
  }
}



resource "aws_route_table" "vpc_route_table" {
  count = var.vpc_id == null ? 1 : 0
  vpc_id = local.vpc_id

  route {
    # Associated subet can reach public internet
    cidr_block = "0.0.0.0/0"

    # Which internet gateway to use
    gateway_id = aws_internet_gateway.vpc_internet_gateway[0].id
  }

  tags = {
    Name = "${var.prefix}-public-custom-rtb"
    Owner = var.owner
  }
}

resource "aws_route_table_association" "custom-rtb-public-subnet" {
  count          = var.number_of_public_subnets
  route_table_id = aws_route_table.vpc_route_table[0].id
  subnet_id      = aws_subnet.vpc_public_subnet.*.id[count.index]
} 

