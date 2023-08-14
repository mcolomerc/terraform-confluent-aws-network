## Data Sources
# -----------------------------------------------------------
# Confluent Cloud Environment 
data "confluent_environment" "main" {
  id = var.environment
}


# -----------------------------------------------------------
## Resources
resource "confluent_network" "aws-private-link" {
  display_name     = var.confluent_network_name
  cloud            = "AWS"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones            = slice(data.aws_availability_zones.available.zone_ids, 0, 3)
  dns_config {
    resolution = "PRIVATE"
  }
  environment {
    id = data.confluent_environment.main.id
  }

  // lifecycle {
  //  prevent_destroy = true
  // }
}

resource "confluent_private_link_access" "aws" {
  display_name = "${var.confluent_network_name} Access"
  aws {
    account = var.aws_account_id
  }
  environment {
    id = data.confluent_environment.main.id
  }
  network {
    id = confluent_network.aws-private-link.id
  }
  // lifecycle {
  // prevent_destroy = true
  // }
}

## AWS VPC Endpoint

# AWS Availability Zones
data "aws_availability_zones" "available" {}

# AWS VPC
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# AWS Subnets query
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [true]
  }
}
data "aws_subnet" "vpc_live" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.key
}

 

locals {
  availability_zone_subnets = { for s in data.aws_subnet.vpc_live : s.availability_zone => s.id... }
}
 

## AWS ENDPOINT SECURITY GROUP
resource "aws_security_group" "privatelink" {
  # Ensure that SG is unique, so that this module can be used multiple times within a single VPC
  name        = "${var.prefix}-privatelink-sg"
  description = "Confluent Cloud Private Link minimal security group in ${var.vpc_id}"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    # only necessary if redirect support from http/https is desired
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }
}
## AWS ENDPOINT
resource "aws_vpc_endpoint" "privatelink" { 
  vpc_id            = data.aws_vpc.selected.id
  service_name      = confluent_network.aws-private-link.aws[0].private_link_endpoint_service
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.privatelink.id,
  ]

  subnet_ids          = data.aws_subnets.selected.ids
  private_dns_enabled = false

  tags = {
    Name = "${var.prefix}-privatelink"
    Owner = "${var.owner}"
  }

  depends_on = [
    confluent_private_link_access.aws,
  ]
}

# HOSTED ZONE
resource "aws_route53_zone" "privatelink" {
  name = confluent_network.aws-private-link.dns_domain
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
}

resource "aws_route53_record" "privatelink" {
  count   = length(data.aws_subnets.selected) == 1 ? 0 : 1
  zone_id = aws_route53_zone.privatelink.zone_id
  name    = "*.${aws_route53_zone.privatelink.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [
    aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]
  ]
}

locals {
  endpoint_prefix = split(".", aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"])[0]
}

 
resource "aws_route53_record" "privatelink-zonal" {
  for_each = data.aws_subnet.vpc_live

  zone_id = aws_route53_zone.privatelink.zone_id
  name    = length(data.aws_subnet.vpc_live) == 1 ? "*" : "*.${data.aws_subnet.vpc_live[each.key].availability_zone_id}"
  type    = "CNAME"
  ttl     = "60"
  records = [
    format("%s-%s%s",
      local.endpoint_prefix,
      data.aws_subnet.vpc_live[each.key].availability_zone,
      replace(aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"], local.endpoint_prefix, "")
    )
  ]
}

 
