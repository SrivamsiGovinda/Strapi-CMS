resource "aws_ecr_repository" "strapi" {
  name                 = "strapi-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "strapi-ecr"
  }
  force_delete = true
}

output "repository_url" {
  value = aws_ecr_repository.strapi.repository_url
}