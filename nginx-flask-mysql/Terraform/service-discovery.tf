resource "aws_service_discovery_http_namespace" "app1_dev" {
  name = "app1-dev"
}

resource "aws_service_discovery_http_namespace" "app1_qa" {
  name = "app1-qa"
}

resource "aws_service_discovery_http_namespace" "app1_uat" {
  name = "app1-uat"
}

resource "aws_service_discovery_http_namespace" "app1_prod" {
  name = "app1-prod"
}