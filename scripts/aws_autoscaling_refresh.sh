#!/usr/bin/env bash

# Refresh ASG by tag

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $(basename "$0") <NAME>"
  echo "Where <NAME> is the value of the 'Name' Tag"
  exit 1
fi

name=$1
group_name=$(aws autoscaling describe-auto-scaling-groups | jq -rM ".AutoScalingGroups[] | select(.Tags[].Key == \"Name\" and .Tags[].Value == \"$name\") | .AutoScalingGroupName")
refresh_id=$(aws autoscaling start-instance-refresh --auto-scaling-group-name "$group_name" --query InstanceRefreshId --output text)
printf "Refresh started: %s, waiting for completion" "$refresh_id"

refresh_status_prev=Pending
refresh_percent_prev=0
refresh_status=Pending
wait_statuses=(Pending InProgress)
while [[ " ${wait_statuses[*]} " =~ ${refresh_status} ]]; do
  sleep 5
  refresh=$(aws autoscaling describe-instance-refreshes --auto-scaling-group-name "$group_name" --instance-refresh-ids "$refresh_id" --query InstanceRefreshes[0])
  refresh_status=$(echo "$refresh" | jq -rM .Status)
  refresh_percent=$(echo "$refresh" | jq -rM '.PercentageComplete // 0')

  if [ "$refresh_status" == $refresh_status_prev ] && [ "$refresh_percent" == $refresh_percent_prev ]; then
    printf "."
  else
    printf "\nRefresh %s, %s percent done" "$refresh_status" "$refresh_percent"
  fi
  refresh_status_prev=$refresh_status
  refresh_percent_prev=$refresh_percent
done
