# AWS Region
variable "region" {
  type = string
  default = "eu-east-1"
}

# AWS Availability Zones - Public Subnets
variable "number_of_public_subnets" {
  type = number
  default = 0
}

# AWS Availability Zones - Private Subnets
variable "number_of_private_subnets" {
  type = number
  default = 3
}

# AWS Prefix Tags
variable "prefix" {
 type = string
}

# AWS Owner Tag
variable "owner" {
 type = string
}

# AWS EC2 Instance
variable "instance" {
    type = object({
        name = string
        type = string 
    }) 
}
 