resource "shoreline_notebook" "application_load_balancer_health_check_failure_during_green_deployment_for_aws_ecs_fargate" {
  name       = "application_load_balancer_health_check_failure_during_green_deployment_for_aws_ecs_fargate"
  data       = file("${path.module}/data/application_load_balancer_health_check_failure_during_green_deployment_for_aws_ecs_fargate.json")
  depends_on = [shoreline_action.invoke_ecs_task_ips,shoreline_action.invoke_cluster_update,shoreline_action.invoke_ecs_status_check]
}

resource "shoreline_file" "ecs_task_ips" {
  name             = "ecs_task_ips"
  input_file       = "${path.module}/data/ecs_task_ips.sh"
  md5              = filemd5("${path.module}/data/ecs_task_ips.sh")
  description      = "List all the tasks registered to the specified target group"
  destination_path = "/tmp/ecs_task_ips.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cluster_update" {
  name             = "cluster_update"
  input_file       = "${path.module}/data/cluster_update.sh"
  md5              = filemd5("${path.module}/data/cluster_update.sh")
  description      = "Update the load balancer configuration to ensure that only one ECS service or port is registered to one target group."
  destination_path = "/tmp/cluster_update.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "ecs_status_check" {
  name             = "ecs_status_check"
  input_file       = "${path.module}/data/ecs_status_check.sh"
  md5              = filemd5("${path.module}/data/ecs_status_check.sh")
  description      = "Check the current status of the ECS Service and tasks to determine whether they are running correctly."
  destination_path = "/tmp/ecs_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_ecs_task_ips" {
  name        = "invoke_ecs_task_ips"
  description = "List all the tasks registered to the specified target group"
  command     = "`chmod +x /tmp/ecs_task_ips.sh && /tmp/ecs_task_ips.sh`"
  params      = ["TARGET_GROUP_ARN","CLUSTER_NAME"]
  file_deps   = ["ecs_task_ips"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_task_ips]
}

resource "shoreline_action" "invoke_cluster_update" {
  name        = "invoke_cluster_update"
  description = "Update the load balancer configuration to ensure that only one ECS service or port is registered to one target group."
  command     = "`chmod +x /tmp/cluster_update.sh && /tmp/cluster_update.sh`"
  params      = ["CONTAINER_PORT","CONTAINER_NAME","TARGET_GROUP_ARN","CLUSTER_NAME"]
  file_deps   = ["cluster_update"]
  enabled     = true
  depends_on  = [shoreline_file.cluster_update]
}

resource "shoreline_action" "invoke_ecs_status_check" {
  name        = "invoke_ecs_status_check"
  description = "Check the current status of the ECS Service and tasks to determine whether they are running correctly."
  command     = "`chmod +x /tmp/ecs_status_check.sh && /tmp/ecs_status_check.sh`"
  params      = ["SERVICE_NAME","CLUSTER_NAME"]
  file_deps   = ["ecs_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.ecs_status_check]
}

