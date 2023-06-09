# AWS & Confluent Cloud Networking Terraform module

Terraform module which creates VPC resources on AWS and Confluent Cloud networking resources.

## AWS Resources

* VPC
* Subnets
* Internet Gateway
* Route Table
* Route Table Association
* Bastion host
  
* Network type: TRANSITGATEWAY
  * Transit Gateway
  * Transit Gateway Attachment
  * Transit Gateway Route Table

## Confluent Cloud Resources

* Confluent Cloud Network
  * Network type: TRANSITGATEWAY
    * Transit Gateway
    * Transit Gateway Attachment
  
## Credentials

### AWS Credentials

`export AWS_ACCESS_KEY_ID="anaccesskey"`

`export AWS_SECRET_ACCESS_KEY="asecretkey"`

### Confluent Cloud Credentials

`export TF_VAR_confluent_cloud_api_key="<API-KEY>"`  

`export TF_VAR_confluent_cloud_api_secret="<API-SECRET>"`

## Bastion host

`mv <prefix>-key-pair.pem ~/.ssh/`

`cd ~/.ssh/`

`chmod 400 <prefix>-key-pair.pem`

`ssh -i "<prefix>-key-pair.pem" ubuntu@<outputs.bastion.public_dns>`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.0.1 |
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | 1.42.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws"></a> [aws](#module\_aws) | ./modules/aws | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ./modules/tgw | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws"></a> [aws](#input\_aws) | AWS | <pre>object({<br>    region = string<br>    prefix = string<br>    owner = string<br>    vpc = object({<br>      number_of_public_subnets = number<br>      number_of_private_subnets = number <br>    })<br>    instance = object({<br>        name = string<br>        type = string <br>    })<br>  })</pre> | n/a | yes |
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API KEY. export TF\_VAR\_confluent\_cloud\_api\_key="API\_KEY" | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API KEY. export TF\_VAR\_confluent\_cloud\_api\_secret="API\_SECRET" | `string` | n/a | yes |
| <a name="input_confluent_network"></a> [confluent\_network](#input\_confluent\_network) | n/a | <pre>object({<br>    display_name = string  <br>    connection_type = string<br>    cidr = optional(string)<br>    zones = optional(list(string))<br>    dns = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion"></a> [bastion](#output\_bastion) | n/a |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_transit_gateay_confluent_network"></a> [transit\_gateay\_confluent\_network](#output\_transit\_gateay\_confluent\_network) | n/a |
| <a name="output_transit_gateay_route"></a> [transit\_gateay\_route](#output\_transit\_gateay\_route) | n/a |
| <a name="output_transit_gateway"></a> [transit\_gateway](#output\_transit\_gateway) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->