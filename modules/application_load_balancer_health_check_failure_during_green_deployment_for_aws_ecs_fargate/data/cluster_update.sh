

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