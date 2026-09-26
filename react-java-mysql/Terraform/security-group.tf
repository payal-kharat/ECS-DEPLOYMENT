# ============================================================
# ECS SECURITY GROUP
# ============================================================

resource "aws_security_group" "ecs" {

  name        = "${var.project_name}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = data.aws_vpc.main.id

  # ----------------------------------------------------------
  # Frontend traffic
  #
  # ALB -> Frontend ECS :80
  # ----------------------------------------------------------

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # ----------------------------------------------------------
  # Backend traffic
  #
  # ALB -> Backend ECS :5000
  # ----------------------------------------------------------

  ingress {
    description     = "Allow backend traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # ----------------------------------------------------------
  # MySQL traffic
  #
  # Backend ECS -> Database ECS :3306
  # ----------------------------------------------------------

  ingress {
    description     = "Allow MySQL from ECS services"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # ----------------------------------------------------------
  # Outbound
  # ----------------------------------------------------------

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}