resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  name   = "strapi-ecs-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "strapi-ecs-sg"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "strapi-cluster"
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "strapi-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "strapi-ecs-execution-policy"
  role = aws_iam_role.ecs_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "strapi" {
  for_each                 = toset(["prod", "staging"])
  family                   = "strapi-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "strapi-${each.key}"
      image = "${var.ecr_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      environment = [
        {
          name  = "DATABASE_CLIENT"
          value = "mysql"
        },
        {
          name  = "DATABASE_HOST"
          value = var.aurora_endpoints[each.key]
        },
        {
          name  = "DATABASE_PORT"
          value = "3306"
        },
        {
          name  = "DATABASE_NAME"
          value = var.aurora_db_names[each.key]
        },
        {
          name  = "DATABASE_USERNAME"
          value = "admin"
        }
      ]
      secrets = [
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = var.aurora_secrets[each.key]
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi[each.key].name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "strapi"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "strapi" {
  for_each         = toset(["prod", "staging"])
  name             = "strapi-${each.key}-service"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.strapi[each.key].arn
  launch_type      = "FARGATE"
  desired_count    = 1
  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi[each.key].arn
    container_name   = "strapi-${each.key}"
    container_port   = 1337
  }
}

resource "aws_lb" "strapi" {
  for_each           = toset(["prod", "staging"])
  name               = "strapi-${each.key}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups     = [aws_security_group.ecs.id]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "strapi-${each.key}-alb"
  }
}

resource "aws_lb_target_group" "strapi" {
  for_each     = toset(["prod", "staging"])
  name         = "strapi-${each.key}-tg"
  port         = 1337
  protocol     = "HTTP"
  vpc_id       = var.vpc_id
  target_type  = "ip"
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_listener" "strapi" {
  for_each          = toset(["prod", "staging"])
  load_balancer_arn = aws_lb.strapi[each.key].arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi[each.key].arn
  }
}

resource "aws_cloudwatch_log_group" "strapi" {
  for_each          = toset(["prod", "staging"])
  name              = "/ecs/strapi-${each.key}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  for_each               = toset(["prod", "staging"])
  alarm_name             = "strapi-${each.key}-cpu-high"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 2
  metric_name            = "CPUUtilization"
  namespace              = "AWS/ECS"
  period                 = 300
  statistic              = "Average"
  threshold              = 80
  alarm_description      = "High CPU utilization for Strapi ${each.key} service"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.strapi[each.key].name
  }
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "prod_alb_dns" {
  value = aws_lb.strapi["prod"].dns_name
}

output "staging_alb_dns" {
  value = aws_lb.strapi["staging"].dns_name
}