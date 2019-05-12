THIS IS WORK IN PROGRES
===========================================

# aws-gcp-vpn-demo
Demo: 
1. Deploy a 3 tier WordPress application in in AWS
2. Create a GCP project. 
3. Set up the VPN 
4. Migrate the EC2 instance to GCE

## Develop
The only dependency that you need is Docker.

First, build the `aws-terraform` image:
```
cd images/aws-terraform
make build
```

Then go to `wp-aws-3tier/Readme.md` and follow the instructions.
