#!/bin/bash
gcloud auth activate-service-account --key-file /root/.gcp/terraform_sa.json 
gcloud config set project ${GCP_PROJECT}
echo Updating instance group...
gcloud compute instance-groups unmanaged add-instances wp-group --zone ${GCP_ZONE} --instances wp-server-0
gcloud compute instance-groups unmanaged add-instances wp-group --zone ${GCP_ZONE} --instances wp-server-1