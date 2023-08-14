



# Create the Confluent Network for the tgw
resource "confluent_network" "tgw" {
  display_name     = "${var.prefix}-tgw-${var.confluent_network_name}" 
  cloud            = "AWS"
  region           = var.region
  cidr             = "192.168.0.0/16"
  zones            = slice(data.aws_availability_zones.available.zone_ids, 0, 3)
  connection_types = ["TRANSITGATEWAY"]
  environment {
    id = data.confluent_environment.main.id
  }
} 

# create tgw in AWS Network Account 
resource "aws_ec2_transit_gateway" "tgw" { 
  description                     = "${var.prefix} Transit Gateway for Confluent Cloud"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "enable"
  tags = {
    Name        = "${var.prefix}-tgw"
    Owner = var.owner
  }
} 

# Create an attachment for the peer, AWS, VPC to the transit gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  subnet_ids         = toset(data.aws_subnets.selected.ids) 
  vpc_id             = data.aws_vpc.selected.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}  

# Create routes from the subnets to the transit gateway CIDR
resource "aws_route" "tgw" {
  route_table_id         = var.route_table_id
  destination_cidr_block = confluent_network.tgw.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}


# Configure ram share
resource "aws_ram_resource_share" "confluent" {
  name                      = "${var.prefix}--share-with-confluent"
  allow_external_principals = true 
}

resource "aws_ram_principal_association" "confluent" {
  principal          = confluent_network.tgw.aws[0].account
  resource_share_arn = aws_ram_resource_share.confluent.arn
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.confluent.arn
}


resource "confluent_transit_gateway_attachment" "tgw" {
  display_name = "AWS Transit Gateway Attachment"
  aws {
    ram_resource_share_arn = aws_ram_resource_share.confluent.arn
    transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
    routes                 = var.routes
  }
  environment {
    id = data.confluent_environment.main.id
  }
  network {
    id = confluent_network.tgw.id
  }
} 
 
 