#AWS
aws = {
    region = "eu-central-1",
    prefix = "mcol",
    owner = "mcolomercornejo@confluent.io",
    vpc = {
      id = "vpc-08a7122ab9509d860" 
    } 
    account_id = "492737776546"
}

# Confluent 
environment = "env-zmz2zd"

confluent_network = {
    display_name = "confluent-network"
    connection_type = "TRANSITGATEWAY" 
    cidr = "192.168.0.0/16"
}
  