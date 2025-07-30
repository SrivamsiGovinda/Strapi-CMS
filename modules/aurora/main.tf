resource "aws_security_group" "aurora" {
  vpc_id = var.vpc_id
  name   = "strapi-aurora-sg"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "strapi-aurora-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "strapi-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "strapi-aurora-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  for_each                  = toset(["prod", "staging"])
  cluster_identifier        = "strapi-aurora-${each.key}"
  engine                    = "aurora-mysql"
  engine_version            = "8.0"
  database_name             = "strapi_${each.key}"
  master_username           = "admin"
  master_password           = aws_secretsmanager_secret_version.db_password[each.key].secret_string
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.aurora.id]
  availability_zones        = ["us-east-1a", "us-east-1b"]
  backup_retention_period   = 7
  preferred_backup_window   = "07:00-09:00"
  skip_final_snapshot       = true
  tags = {
    Name = "strapi-aurora-${each.key}"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  for_each            = toset(["prod", "staging"])
  identifier          = "strapi-aurora-instance-${each.key}"
  cluster_identifier  = aws_rds_cluster.aurora[each.key].id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  publicly_accessible = false
}

resource "aws_secretsmanager_secret" "db_password" {
  for_each = toset(["prod", "staging"])
  name     = "strapi-${each.key}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  for_each      = toset(["prod", "staging"])
  secret_id     = aws_secretsmanager_secret.db_password[each.key].id
  secret_string = random_password.db_password[each.key].result
}

resource "random_password" "db_password" {
  for_each = toset(["prod", "staging"])
  length   = 16
  special  = false
}

resource "aws_cloudwatch_metric_alarm" "aurora_cpu" {
  for_each               = toset(["prod", "staging"])
  alarm_name             = "strapi-aurora-${each.key}-cpu-high"
  comparison_operator    = "GreaterThanThreshold"
  evaluation_periods     = 2
  metric_name            = "CPUUtilization"
  namespace              = "AWS/RDS"
  period                 = 300
  statistic              = "Average"
  threshold              = 80
  alarm_description      = "High CPU utilization for Aurora ${each.key} cluster"
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora[each.key].id
  }
}

output "endpoints" {
  value = { for env in ["prod", "staging"] : env => aws_rds_cluster.aurora[env].endpoint }
}

output "db_names" {
  value = { for env in ["prod", "staging"] : env => "strapi_${env}" }
}

output "secrets" {
  value = { for env in ["prod", "staging"] : env => aws_secretsmanager_secret.db_password[env].arn }
}