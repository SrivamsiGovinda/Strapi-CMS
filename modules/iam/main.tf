resource "aws_iam_user" "github_actions" {
  name = "github-actions-user"
  tags = {
    Name = "strapi-github-actions-user"
  }
}

resource "aws_iam_user_policy" "github_actions_policy" {
  name = "github-actions-policy"
  user = aws_iam_user.github_actions.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecs:*",
          "rds:*",
          "secretsmanager:*",
          "logs:*",
          "route53:*",
          "elasticloadbalancing:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

output "access_key_id" {
  value     = aws_iam_access_key.github_actions.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}