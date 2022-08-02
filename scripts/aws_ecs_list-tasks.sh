#!/usr/bin/env bash

describe_tasks(){
  # shellcheck disable=SC2016,SC2086
  aws ecs describe-tasks --cluster "$1" --tasks $2 --query 'tasks[*].{taskArn: taskArn, ip: attachments[0].details[?name==`privateIPv4Address`].value | [0]}'
}
export -f describe_tasks

describe_cluster(){
  tasks=$(aws ecs list-tasks --cluster "$1" --query taskArns --output text)
  [ -n "$tasks" ] && describe_tasks "$1" "$tasks"
}
export -f describe_cluster

aws ecs list-clusters --query clusterArns --output text | xargs -n1 -I{} sh -c 'describe_cluster {}'
