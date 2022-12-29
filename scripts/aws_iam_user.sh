#!/usr/bin/env bash

# Fetch IAM role and policy json
# Assumes
# - awscli is installed
# - jq is installed

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Invalid parameters!"
  echo "Usage: AWS_PROFILE=... $0 <username>"
  exit 1
fi

get_policy_json(){
  # shellcheck disable=SC2016
  version_id=$(aws iam list-policy-versions --policy-arn "$1" --query 'Versions[?IsDefaultVersion==`true`].VersionId' --output text)
  aws iam get-policy-version --version-id "$version_id" --policy-arn "$1"
}
export -f get_policy_json

username=$1
aws iam list-user-policies --user-name "${username}" --query 'PolicyNames' --output text | sed 's/\t\t*/\n/g' | sort | xargs -t -I{} sh -c "aws iam get-user-policy --user-name ${username} --policy-name {}"
aws iam list-attached-user-policies --user-name "${username}" --query 'AttachedPolicies[].PolicyArn' --output text | sed 's/\t\t*/\n/g' | sort | xargs -I{} sh -c 'get_policy_json {}'
