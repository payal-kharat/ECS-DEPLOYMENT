resource "aws_lb" "frontend" {

  for_each = local.service_environments

  name = "emp-${each.key}-frontend-alb"

  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = data.aws_subnets.main.ids

  enable_deletion_protection = false
}


resource "aws_lb_listener" "frontend" {

  for_each = local.service_environments

  load_balancer_arn = aws_lb.frontend[each.key].arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend[each.key].arn
  }
}


resource "aws_lb_listener_rule" "backend_api" {

  for_each = local.service_environments

  listener_arn = aws_lb_listener.frontend[each.key].arn

  priority = 10

  action {
    type             = "forward"

    target_group_arn = aws_lb_target_group.backend[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}