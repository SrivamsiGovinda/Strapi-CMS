provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {
  default = "srivamsi.com"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# Aurora Module
module "aurora" {
  source           = "./modules/aurora"
  vpc_id           = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_security_group_id = module.ecs.ecs_security_group_id
}

# ECS Module
module "ecs" {
  source            = "./modules/ecs"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  aurora_endpoints  = module.aurora.endpoints
  aurora_db_names   = module.aurora.db_names
  aurora_secrets    = module.aurora.secrets
  ecr_repository_url = module.ecr.repository_url
}

# Route53 Module
module "route53" {
  source         = "./modules/route53"
  domain_name    = var.domain_name
  prod_alb_dns   = module.ecs.prod_alb_dns
  staging_alb_dns = module.ecs.staging_alb_dns
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
}

# IAM Module
module "iam" {
  source = "./modules/iam"
}

output "aws_access_key_id" {
  value     = module.iam.access_key_id
  sensitive = true
}

output "aws_secret_access_key" {
  value     = module.iam.secret_access_key
  sensitive = true
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}