locals {
  service_environments = {
    dev = {
      cluster   = aws_ecs_cluster.dev.id
      namespace = aws_service_discovery_http_namespace.app1_dev.arn
    }

    qa = {
      cluster   = aws_ecs_cluster.qa.id
      namespace = aws_service_discovery_http_namespace.app1_qa.arn
    }

    uat = {
      cluster   = aws_ecs_cluster.uat.id
      namespace = aws_service_discovery_http_namespace.app1_uat.arn
    }

    prod = {
      cluster   = aws_ecs_cluster.prod.id
      namespace = aws_service_discovery_http_namespace.app1_prod.arn
    }
  }
}


# ============================================================
# FRONTEND ECS SERVICE
# ============================================================

resource "aws_ecs_service" "frontend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-frontend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.frontend[each.key].arn

  desired_count = 1
  launch_type   = "FARGATE"

  # ----------------------------------------------------------
  # ECS SERVICE CONNECT
  # Frontend acts as a client of Backend
  # ----------------------------------------------------------

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace
  }

  # ----------------------------------------------------------
  # LOAD BALANCER
  # Frontend container listens on port 80
  # ----------------------------------------------------------

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend[each.key].arn
    container_name   = "frontend"
    container_port   = 80
  }

  # ----------------------------------------------------------
  # NETWORK CONFIGURATION
  # ----------------------------------------------------------

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_lb_listener.frontend
  ]
}


# ============================================================
# BACKEND ECS SERVICE
# ============================================================

resource "aws_ecs_service" "backend" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-backend-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.backend[each.key].arn

  desired_count = 1
  launch_type   = "FARGATE"

  # ----------------------------------------------------------
  # ECS SERVICE CONNECT
  # ----------------------------------------------------------

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace

    service {
      port_name      = "backend"
      discovery_name = "app3-backend"

      client_alias {
        port     = 8080
        dns_name = "app3-backend"
      }
    }
  }

  # ----------------------------------------------------------
  # LOAD BALANCER
  #
  # Backend container listens on port 5000.
  # ALB sends /api/* requests to this target group.
  # ----------------------------------------------------------

  load_balancer {
    target_group_arn = aws_lb_target_group.backend[each.key].arn
    container_name   = "backend"
    container_port   = 8080
  }

  # ----------------------------------------------------------
  # NETWORK CONFIGURATION
  # ----------------------------------------------------------

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_lb_listener_rule.backend_api
  ]
}


# ============================================================
# DATABASE ECS SERVICE
# ============================================================

resource "aws_ecs_service" "db" {
  for_each = local.service_environments

  name            = "${var.project_name}-${each.key}-db-service"
  cluster         = each.value.cluster
  task_definition = aws_ecs_task_definition.db[each.key].arn

  desired_count = 1
  launch_type   = "FARGATE"

  # ----------------------------------------------------------
  # ECS SERVICE CONNECT
  # ----------------------------------------------------------

  service_connect_configuration {
    enabled   = true
    namespace = each.value.namespace

    service {
      port_name      = "mysql"
      discovery_name = "app3-db"

      client_alias {
        port     = 3306
        dns_name = "app3-db"
      }
    }
  }

  # ----------------------------------------------------------
  # NETWORK CONFIGURATION
  # ----------------------------------------------------------

  network_configuration {
    subnets          = data.aws_subnets.main.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}