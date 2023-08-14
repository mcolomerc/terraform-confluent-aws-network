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

variable "vpc_id" {
    type = string
}