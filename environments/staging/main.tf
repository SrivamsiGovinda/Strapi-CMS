provider "aws" {
    region = "us-east-1"
}

variable "domain_name" {
    default = "srivamsi.com"
}

variable "github_repo" {
    default = "SrivamsiGovinda/Strapi-CMS"
}

#VPC Module
module "vpc" {
    source = "../../modules/vpc"
}

#Aurora Module
module "aurora" {
    source = "../../modules/aurora"
    vpc_id = module.vpc.vpc_id
}