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
          "iam:*",
          "secretsmanager:*",
          "logs:*",
          "route53:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "S3:PutObject",
          "S3:GetObject",
          "S3:DeleteObjecgt",
          "s3:ListBucket",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:CreateTable",
          "ec2:DescribeVpcs",
          "ec2:DeleteSubnet",
          "ec2:DeleteRouteTable",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeRouteTables",
          "ec2:DisassociateRouteTable",
          "ec2:DeleteRoute",
          "secretsmanager:DescribeSecret",
          "secretsmanager:DeleteSecret",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup"
        ]
        Resource = [
          "arn:aws:s3:::strapi-terraform-state",
          "arn:aws:s3:::strapi-terraform-state/*",
          "arn:aws:dynamodb:us-east-1:*:table/strapi-terraform-lock",
          "arn:aws:iam::*:user/github-actions-user",
          "arn:aws:iam::*:policy/strapi-github-actions-policy",
          "arn:aws:iam::*:role/strapi-ecs-execution-role",
          "arn:aws:iam::*:policy/strapi-ecs-execution-policy",
          "arn:aws:ec2:us-east-1:*:vpc/*",
          "arn:aws:ec2:us-east-1:*:subnet/*",
          "arn:aws:ec2:us-east-1:*:route-table/*",
          "arn:aws:ec2:us-east-1:*:internet-gateway/*",
          "arn:aws:ec2:us-east-1:*:security-group/*",
          "arn:aws:ec2:us-east-1:*:network-interface/*",
          "arn:aws:elasticloadbalancing:us-east-1:*:loadbalancer/app/strapi-*",
          "arn:aws:elasticloadbalancing:us-east-1:*:targetgroup/strapi-*",
          "arn:aws:elasticloadbalancing:us-east-1:*:listener/app/strapi-*/*",
          "arn:aws:rds:us-east-1:*:cluster:strapi-*",
          "arn:aws:rds:us-east-1:*:db:*",
          "arn:aws:rds:us-east-1:*:subgrp:strapi-*",
          "arn:aws:secretsmanager:us-east-1:*:secret:strapi-*",
          "arn:aws:logs:us-east-1:*:log-group:/ecs/strapi-*",
          "arn:aws:ecs:us-east-1:*:cluster/strapi-cluster",
          "arn:aws:ecs:us-east-1:*:service/strapi-cluster/strapi-*",
          "arn:aws:ecs:us-east-1:*:task/strapi-cluster/*",
          "arn:aws:ecr:us-east-1:*:repository/strapi-app"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:*",
          "ecs:*",
          "rds:*",
          "secretsmanager:*",
          "logs:*",
          "route53:*",
          "elasticloadbalancing:*",
          "cloudwatch:*"
        ],
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

resource "aws_iam_user_policy_attachment" "github_actions_policy_attachment" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

output "access_key_id" {
  value     = aws_iam_access_key.github_actions.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}