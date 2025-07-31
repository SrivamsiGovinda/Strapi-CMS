variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "aurora_endpoints" {
  type = map(string)
}

variable "aurora_db_names" {
  type = map(string)
}

variable "aurora_secrets" {
  type = map(string)
}

variable "ecr_repository_url" {
  type = string
}