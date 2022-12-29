#!/usr/bin/env bash

# Fetch Cluster and Steps
# Assumes
# - awscli is installed

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <CLUSTER ID>"
  exit 1
fi

aws emr describe-cluster --cluster-id "$1"
aws emr list-steps --cluster-id "$1"
