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