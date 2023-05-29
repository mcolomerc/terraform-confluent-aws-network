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
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name
 
  tags = {
    Name = "${var.prefix}-vpc"
    Owner = var.owner
  }
}

resource "aws_subnet" "vpc_public_subnet" {
  # Number of public subnet is defined in vars
  count = var.number_of_public_subnets

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + var.number_of_private_subnets}.0/24"
  vpc_id                  = aws_vpc.vpc.id
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
  vpc_id            = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index}"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
    Owner = var.owner
  }
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    # Associated subet can reach public internet
    cidr_block = "0.0.0.0/0"

    # Which internet gateway to use
    gateway_id = aws_internet_gateway.vpc_internet_gateway.id
  }

  tags = {
    Name = "${var.prefix}-public-custom-rtb"
    Owner = var.owner
  }
}

resource "aws_route_table_association" "custom-rtb-public-subnet" {
  count          = var.number_of_public_subnets
  route_table_id = aws_route_table.vpc_route_table.id
  subnet_id      = aws_subnet.vpc_public_subnet.*.id[count.index]
} 

# Create a AWS EC2 for external access
resource "aws_security_group" "bastion-sg" {
  name = "${var.prefix}-sg"
  description = "${var.prefix}-sg"
  vpc_id =  aws_vpc.vpc.id 
  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  } 
 
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  } 
  lifecycle {
    create_before_destroy = true
  }
}

#KEY PAIR 
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-key-pair" {
  key_name = "${var.prefix}-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.rsa.private_key_pem}' > ./${var.prefix}-key-pair.pem"
  }
} 

# AMI
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}



## AWS INSTANCE
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = var.instance.type
  subnet_id = aws_subnet.vpc_public_subnet[0].id
  associate_public_ip_address = true
  key_name = aws_key_pair.tf-key-pair.key_name 

  vpc_security_group_ids = [
    aws_security_group.bastion-sg.id
  ]

  root_block_device {
    delete_on_termination = true 
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.prefix}-bastion" 
    Owner = var.owner
  }

  depends_on = [ aws_security_group.bastion-sg ]
}

