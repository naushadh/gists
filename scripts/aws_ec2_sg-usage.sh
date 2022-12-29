#!/usr/bin/env bash

# Fetch network interfaces attached to an SG
# https://aws.amazon.com/premiumsupport/knowledge-center/ec2-find-security-group-resources/#Method_2.3A_Use_the_AWS_CLI
# Assumes
# - awscli is installed

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <SecurityGroup Id>"
  exit 1
fi

group_id=$1
region=$(aws configure get region)
aws ec2 describe-network-interfaces --filters Name=group-id,Values="$group_id" --region "$region" --output json --query 'NetworkInterfaces[*]'.['NetworkInterfaceId','Description','PrivateIpAddress','VpcId']
