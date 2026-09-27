resource "aws_service_discovery_http_namespace" "app1_dev" {
  name = "app2-dev"
}

resource "aws_service_discovery_http_namespace" "app1_qa" {
  name = "app2-qa"
}

resource "aws_service_discovery_http_namespace" "app1_uat" {
  name = "app2-uat"
}

resource "aws_service_discovery_http_namespace" "app1_prod" {
  name = "app2-prod"
}