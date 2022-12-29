#!/usr/bin/env bash

# Find elasticache info for a cluster hostname
# Assumes
# - awscli is installed
# - jq is installed

set -euo pipefail

find_encrypted(){
  aws elasticache describe-replication-groups | jq ".ReplicationGroups[] | select(.NodeGroups[].PrimaryEndpoint.Address == \"$1\") | {ReplicationGroupId, TransitEncryptionEnabled, AtRestEncryptionEnabled}"
}

find_simple(){
  aws elasticache describe-cache-clusters --show-cache-node-info | jq ".CacheClusters[] | select(.CacheNodes[].Endpoint.Address == \"$1\") | {ReplicationGroupId, TransitEncryptionEnabled, AtRestEncryptionEnabled}"
}

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <cluster address>"
  exit 1
fi

result=$(find_encrypted "$1")
if [ "$result" == "" ]; then
  result=$(find_simple "$1")
fi

echo "$result"
