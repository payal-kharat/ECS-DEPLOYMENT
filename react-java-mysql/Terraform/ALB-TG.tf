resource "aws_lb_target_group" "frontend" {

  for_each = local.service_environments

  name        = "${var.project_name}-${each.key}-f-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = data.aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30

    matcher = "200-399"
  }
}


resource "aws_lb_target_group" "backend" {

  for_each = local.service_environments

  name        = "${var.project_name}-${each.key}-b-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = data.aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30

    matcher = "200-399"
  }
}


resource "aws_security_group" "alb" {

  name        = "${var.project_name}-alb-sg"
  description = "Security group for frontend ALB"

  vpc_id = data.aws_vpc.main.id

  ingress {
    description = "Allow HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}