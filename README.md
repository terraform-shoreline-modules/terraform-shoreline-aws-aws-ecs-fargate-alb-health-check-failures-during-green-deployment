
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Application Load Balancer Health Check Failure During Green Deployment for AWS ECS Fargate
---

This incident type involves ECS tasks failing Application Load Balancer health checks during a new green deployment in an AWS ECS Fargate environment. In such a scenario, the issue may be caused by multiple ECS services trying to register their tasks to the same green target group, leading to a discrepancy. The recommended troubleshooting step is to update the load balancer configuration to ensure that only one ECS service or port is registered to one target group.

### Parameters
```shell
export CLUSTER_NAME="PLACEHOLDER"

export SERVICE_NAME="PLACEHOLDER"

export TASK_DEFINITION_ARN="PLACEHOLDER"

export LOAD_BALANCER_ARN="PLACEHOLDER"

export TARGET_GROUP_ARN="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export CONTAINER_PORT="PLACEHOLDER"
```

## Debug

### List all the available services in the cluster
```shell
aws ecs list-services --cluster ${CLUSTER_NAME}
```

### Describe the specified ECS service to check its details
```shell
aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME}
```

### Describe the specified task definition
```shell
aws ecs describe-task-definition --task-definition ${TASK_DEFINITION_ARN}
```

### List all the registered target groups of the specified load balancer
```shell
aws elbv2 describe-target-groups --load-balancer-arn ${LOAD_BALANCER_ARN}
```

### List all the tasks registered to the specified target group
```shell
#!/bin/bash



IPs=$(aws elbv2 describe-target-health --target-group-arn ${TARGET_GROUP_ARN} --query 'TargetHealthDescriptions[].Target.Id' --output text)



# For each target IP

for IP in $IPs; do

    # List all task ARNs in the cluster

    TASK_ARNS=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --query "taskArns[]" --output text)



    # For each task ARN, describe the task to get its network configuration

    for TASK_ARN in $TASK_ARNS; do

        TASK_IP=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks $TASK_ARN --query "tasks[0].attachments[0].details[?name=='privateIPv4Address'].value" --output text)

        

        # If the task IP matches the target IP, print it out

        if [[ "$TASK_IP" == "$IP" ]]; then

            TASK_ARN=$TASK_ARN

        fi

    done

done





aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks $TASK_ARN
```

## Repair

### Update the load balancer configuration to ensure that only one ECS service or port is registered to one target group.
```shell


#!/bin/bash



# Set variables

CLUSTER=${CLUSTER_NAME}

TARGET_GROUP_ARN=${TARGET_GROUP_ARN}

CONTAINER_NAME=${CONTAINER_NAME}

CONTAINER_PORT=${CONTAINER_PORT}



# Deregister all targets from the target group

aws elbv2 deregister-targets --target-group-arn $TARGET_GROUP_ARN --targets Id=$(aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN | jq -r '.TargetHealthDescriptions[].Target.Id')



# Update the ECS service 

aws ecs update-service --cluster $CLUSTER --service $SERVICE --load-balancer "[{\"containerName\": \"$CONTAINER_NAME\", \"conatinerPort\": $CONTAINER_PORT, \"targetGroupArn\": \"$TARGET_GROUP_ARN\"}]"



echo "Target group configuration updated successfully."


```

### Check the current status of the ECS Service and tasks to determine whether they are running correctly.
```shell


#!/bin/bash



# Assign Variables

CLUSTER_NAME=${CLUSTER_NAME}

SERVICE_NAME=${SERVICE_NAME}



# Check Status of ECS Cluster

echo "Checking status of ECS Cluster: $CLUSTER_NAME"

cluster_status=$(aws ecs describe-clusters --cluster $CLUSTER_NAME --query "clusters[0].status" --output text)

echo "Cluster Status: $cluster_status"



# Check Status of ECS Service

echo "Checking status of ECS Service: $SERVICE_NAME"

service_status=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --query "services[0].status" --output text)

echo "Service Status: $service_status"


```