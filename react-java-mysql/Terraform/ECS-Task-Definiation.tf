locals {
  environments = {
    dev  = aws_ecs_cluster.dev
    qa   = aws_ecs_cluster.qa
    uat  = aws_ecs_cluster.uat
    prod = aws_ecs_cluster.prod
  }
}

resource "aws_ecs_task_definition" "frontend" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "nginx:1.13-alpine"
      essential = true

      portMappings = [
        {
          name          = "frontend"
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "backend" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "python:3.10-alpine"
      essential = true

      portMappings = [
        {
          name          = "backend"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "db" {
  for_each = local.environments

  family                   = "${var.project_name}-${each.key}-db"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "db"
      image     = "mariadb:10-focal"
      essential = true

      portMappings = [
        {
          name          = "mysql"
          containerPort = 3306
          hostPort      = 3306
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MYSQL_DATABASE"
          value = "example"
        },
        {
          name  = "MYSQL_ROOT_PASSWORD"
          value = "rootpassword"
        }
      ]
    }
  ])
}