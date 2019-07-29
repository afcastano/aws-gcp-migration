# WORK IN PROGRESS

Use terraform to deploy a 3-tier WordPress application in AWS and migrate it to GCP using Velostrata.

This project serves two purposes:
- A tutorial explaining the different steps and concepts to set up and migrate a Word Press application.
- A demo to present the working solution.

## Tutorial contents
- How to deploy a WordPress 3 tier application in AWS
    - Tier 1: Public access - Load balancer and Bastion host
    - Tier 2: Private access - Multiple WordPress servers
    - Tier 3: Private access - DB server
- How to define security groups for each tier
- How to deploy a high availability VPN between GCP and AWS
- How to migrate Tier 2 from AWS to GCP
    - Install and configure Velostrata in GCP
    - Set up runbooks and waves in Velostrata
    - Run a Cloud migration job
- How to set up an external load balancer in GCP for balancing trafic between the migrated instances

## Demo contents
- Prerequisites:
    - The only local dependency is Docker
    - AWS: Obtain a key id and secret
    - GCP: Create a json key file and enable APIs
    - Load keys into environment variables

- Demo steps:
    - Deploy: `make deploy`
    - Accept velostrata eula: `make eula`
    - Open wordpress in aws: `make wp_aws`
    - Run migration: `make velostrata_migrate`
    - Open wordpress in gcp: `make wp_gcp`
    - Clean up resources: `make destroy`