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

# Create a AWS EC2 for external access
resource "aws_security_group" "bastion-sg" {
  count = can(var.instance) ? 1 : 0 
  name = "${var.prefix}-sg"
  description = "${var.prefix}-sg"
  vpc_id =  data.aws_vpc.selected.id
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
  count = var.instance!= null ? 1 : 0 
  instance_type = can(var.instance.type) ? var.instance.type : "t2.micro"
  subnet_id = data.aws_subnets.selected.id
  associate_public_ip_address = true
  key_name = aws_key_pair.tf-key-pair.key_name 

  vpc_security_group_ids = [
    aws_security_group.bastion-sg[0].id
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

