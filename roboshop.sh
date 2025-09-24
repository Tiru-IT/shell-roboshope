#!/bin bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f3a1afbf0bbc7f0e"

for instance in $@
do
     INSTANCE_ID=$( aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0f3a1afbf0bbc7f0e --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output text
)
      if [ $instance -ne frontend ];then
        IP=$(aws ec2 describe-instances --instance-ids i-08aabb98f4bc7ad4e --query 'Reservations[0].Instances[0].PrivetIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids i-08aabb98f4bc7ad4e --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"

done