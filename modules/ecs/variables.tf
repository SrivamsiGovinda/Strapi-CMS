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

variable "app_keys" {
  type = list(string)
  default = ["57f96fdd012c161a8f11f22c2f46b5ec1b6f5d2dfef4207f7c3e29e204c2ad21", "66fd2df7360041ab7d63056bcfe2c9d0611a3f0045b1b908dc8d4d1f116a04c5"]
}