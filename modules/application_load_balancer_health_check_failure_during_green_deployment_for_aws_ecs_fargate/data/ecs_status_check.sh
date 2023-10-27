

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