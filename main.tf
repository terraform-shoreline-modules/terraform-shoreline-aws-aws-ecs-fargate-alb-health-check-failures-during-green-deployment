terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "application_load_balancer_health_check_failure_during_green_deployment_for_aws_ecs_fargate" {
  source    = "./modules/application_load_balancer_health_check_failure_during_green_deployment_for_aws_ecs_fargate"

  providers = {
    shoreline = shoreline
  }
}