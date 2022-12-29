#!/usr/bin/env bash

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <cluster_id>"
  exit 1
fi

cluster_id=$1
log_uri=$(aws emr describe-cluster --cluster-id "$cluster_id" --query Cluster.LogUri --output text | cut -d ':' -f2- | cut -d'/' -f3-)
aws s3 sync s3://"$log_uri$cluster_id" /tmp/"$cluster_id"
find /tmp/"$cluster_id" -name *.gz | xargs gunzip --force
find /tmp/"$cluster_id"/containers/*/*01_000001 -type f -name stdout | xargs code
