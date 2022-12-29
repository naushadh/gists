#!/usr/bin/env bash

aws ec2 describe-instances \
  --filters 'Name=instance-state-name,Values=running' \
  --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value[] | [0], PrivateIpAddress]" \
  --output text |
  grep -i "$1" |
  cut -d$'\t' -f2
