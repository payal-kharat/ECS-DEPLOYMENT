resource "aws_service_discovery_http_namespace" "app1_dev" {
  name = "app3-dev"
}

resource "aws_service_discovery_http_namespace" "app1_qa" {
  name = "app3-qa"
}

resource "aws_service_discovery_http_namespace" "app1_uat" {
  name = "app3-uat"
}

resource "aws_service_discovery_http_namespace" "app1_prod" {
  name = "app3-prod"
}