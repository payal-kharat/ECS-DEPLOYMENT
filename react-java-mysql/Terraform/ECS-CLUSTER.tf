resource "aws_ecs_cluster" "dev" {
  name = "${var.project_name}-dev-cluster"
}

resource "aws_ecs_cluster" "qa" {
  name = "${var.project_name}-qa-cluster"
}

resource "aws_ecs_cluster" "uat" {
  name = "${var.project_name}-uat-cluster"
}

resource "aws_ecs_cluster" "prod" {
  name = "${var.project_name}-prod-cluster"
}