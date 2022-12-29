#!/usr/bin/env bash

set -euo pipefail

environment_type=$(aws ssm get-parameter --name /tenant/environment_type --query Parameter.Value --output text || echo production)
bucket_prefix="quandl-$environment_type"
query_id=$(aws athena start-query-execution --work-group primary --result-configuration OutputLocation=s3://"$bucket_prefix"-scratchpad/athena/ --query-string "$*" --query QueryExecutionId --output text)

status=QUEUED
wait_statuses=(QUEUED)

while [[ " ${wait_statuses[*]} " =~ ${status} ]]; do
  status=$(aws athena get-query-execution --query-execution-id "$query_id" --query QueryExecution.Status.State --output text)
  sleep 1
  echo -n '.'
done
echo ''

aws athena get-query-execution --query-execution-id "$query_id"
if [ "$status" == SUCCEEDED ]; then
  s3_output_uri=$(aws athena get-query-execution --query-execution-id "$query_id" --query QueryExecution.ResultConfiguration.OutputLocation --output text)
  aws s3 cp "$s3_output_uri" ~/Downloads/
  code ~/Downloads/"$(basename "$s3_output_uri")"
fi
