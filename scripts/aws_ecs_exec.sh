#!/usr/bin/env bash

# Shell into an ECS task. Assumes
# - ecs cluster and task-definition are named the same
# - ssh configs are setup already for simple login (ssh $hostname)

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $(basename "$0") <app_name> [... <command_pattern>]"
  exit 1
fi

app_name=$1
command_pattern=${2:-}
CLUSTER=${CLUSTER:-$app_name}
ecr_repo_url=$(aws ecr describe-repositories --repository-names "$app_name" --query repositories[0].repositoryUri --output text)
container_instance=$(aws ecs list-container-instances --cluster "$CLUSTER" --query containerInstanceArns[0] --output text)
instance_id=$(aws ecs describe-container-instances --cluster "$CLUSTER" --container-instances "$container_instance" --query containerInstances[0].ec2InstanceId --output text)
DOCKER_IP=$(aws ec2 describe-instances --instance-ids "$instance_id" --query Reservations[0].Instances[0].PrivateIpAddress --output text)
DOCKER_HOST="ssh://ec2-user@$DOCKER_IP"
export DOCKER_HOST
container_id=$(docker ps | grep "$ecr_repo_url:latest" | grep "$command_pattern" | head -n1 | awk '{ print $1 }')
docker exec -it "$container_id" bash
