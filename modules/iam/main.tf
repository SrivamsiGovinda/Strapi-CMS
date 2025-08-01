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
          "cloudwatch:*",
          "S3:PutObject",
          "S3:GetObject",
          "S3:DeleteObjecgt",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "ec2:DescribeVpcs",
          "ec2:DeleteSubnet",
          "ec2:DeleteRouteTable",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteSecurityGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
  lifecycle {
    create_before_destroy = true
  }
}

output "access_key_id" {
  value     = aws_iam_access_key.github_actions.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}