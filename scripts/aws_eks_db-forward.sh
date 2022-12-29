#!/usr/bin/env bash

# Shell into an EKS database. Assumes
# - aws cli credentials+profiles are setup
# - local port for database (psql) is available

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $(basename "$0") <namespace> <database svc>"
  exit 1
fi

namespace=$1
database=$2

cluster=$(aws eks list-clusters --query clusters --output text  | sed 's/\t\t*/\n/g' | grep ncp)
aws eks update-kubeconfig --name "$cluster"
kubectl port-forward --namespace "$namespace" svc/"$database" 5432:5432
