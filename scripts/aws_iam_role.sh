#!/usr/bin/env bash

# Fetch IAM role and policy json
# Assumes
# - awscli is installed
# - jq is installed

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <role_name>"
  exit 1
fi

get_policy_json(){
  # shellcheck disable=SC2016
  version_id=$(aws iam list-policy-versions --policy-arn "$1" --query 'Versions[?IsDefaultVersion==`true`].VersionId' --output text)
  aws iam get-policy-version --version-id "$version_id" --policy-arn "$1"
}
export -f get_policy_json

role_name=$1
aws iam get-role --role-name "$role_name"
aws iam list-role-policies --role-name "$role_name" --query 'PolicyNames' --output text | sed 's/\t\t*/\n/g' | sort | xargs -t -I{} sh -c "aws iam get-role-policy --role-name $role_name --policy-name {}"
aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[].PolicyArn' --output text | sed 's/\t\t*/\n/g' | sort | xargs -I{} sh -c 'get_policy_json {}'
