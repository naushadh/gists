#!/usr/bin/env bash

# Launch an EMR cluster.

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

get_parameter_value(){
  aws ssm get-parameter --name "$1" --query Parameter.Value --output text
}

environment_type=$(get_parameter_value /tenant/environment_type)
environment_type="$(tr '[:lower:]' '[:upper:]' <<< "${environment_type:0:1}")${environment_type:1}"
vpn_sg=$(get_parameter_value /compute-basics/security_groups/vpn_receive)
subnet_id=$(get_parameter_value /networking/subnet_private_ids | cut -d, -f1)
aws emr create-cluster \
  --applications Name=Spark Name=Zeppelin Name=PrestoSQL \
  --tags "cost=ds" "dev=$(whoami)" \
  --ec2-attributes "{
    \"KeyName\":\"$environment_type-Generic\",
    \"AdditionalMasterSecurityGroups\":[\"$vpn_sg\"],
    \"AdditionalSlaveSecurityGroups\":[\"$vpn_sg\"],
    \"InstanceProfile\":\"EMR_EC2_DefaultRole\",
    \"SubnetId\":\"$subnet_id\"
    }" \
  --service-role EMR_DefaultRole \
  --release-label emr-6.1.0 \
  --name "$(whoami)-$(basename "$0")" \
  --instance-groups '[
    {
      "InstanceCount":1,
      "EbsConfiguration":{
        "EbsBlockDeviceConfigs":[
          {
            "VolumeSpecification":{
              "SizeInGB":500,"VolumeType":"gp2"
            },
            "VolumesPerInstance":1
          }
        ],
        "EbsOptimized":true
      },
      "InstanceGroupType":"CORE",
      "InstanceType":"r5.xlarge",
      "Name":"Core_node"
    },
    {
      "InstanceCount":1,
      "EbsConfiguration":{
        "EbsBlockDeviceConfigs":[
          {
            "VolumeSpecification":{
              "SizeInGB":32,"VolumeType":"gp2"
            },
            "VolumesPerInstance":1
          }
        ]
      },
      "InstanceGroupType":"MASTER",
      "InstanceType":"r5.xlarge",
      "Name":"Master_node"
    }
  ]' --region us-east-1
