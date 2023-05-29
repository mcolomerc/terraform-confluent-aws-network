#AWS
aws = {
    region = "eu-central-1",
    prefix = "mcol",
    owner = "mcolomercornejo@confluent.io",
    vpc = {
      number_of_public_subnets = 3
      number_of_private_subnets = 3 
    }
    instance = {
      name = "mcolomer-central"
      type = "t2.micro" 
    }
}

# Confluent 
environment = "env-zmz2zd"

confluent_network = {
    display_name = "confluent-network"
    connection_type = "TRANSITGATEWAY" 
    cidr = "192.168.0.0/16"
}
  