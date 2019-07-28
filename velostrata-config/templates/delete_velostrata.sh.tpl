#!/bin/bash
gcloud auth activate-service-account --key-file /root/.gcp/terraform_sa.json 
gcloud config set project ${GCP_PROJECT}
echo "Remove instances from group (5 minutes)..."
gcloud compute instance-groups unmanaged remove-instances wp-group --zone ${GCP_ZONE} --instances wp-server-0
gcloud compute instance-groups unmanaged remove-instances wp-group --zone ${GCP_ZONE} --instances wp-server-1
sleep 30
echo Deleting velostrata instances... 
gcloud compute instances list | grep 'velostrata-edge\|wp-server' | awk '{printf "gcloud compute instances delete %s --zone %s -q \n", $1, $2}' | bash 
echo Deleting addresses ... 
gcloud compute addresses list | grep 'velostrata-edge\|wp-server' | awk '{printf "gcloud compute addresses delete %s --region %s -q \n", $1, $5}' | bash 
echo deleting aws instance... 
aws ec2 describe-instances --filter "Name=tag:Name,Values=Velostrata*" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --region ap-southeast-1 | awk 'NR>2 {printf "aws ec2 terminate-instances --instance-ids %s --region ap-southeast-1 \n", last} {gsub(/,/,"")} {last=$0}' | bash	