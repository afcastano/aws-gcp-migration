THIS IS WORK IN PROGRES
===========================================

# Migrate AWS application to GCP Demo

Demo steps:

1. Deploy a 3 tier WordPress application in in AWS
2. Create a GCP project. 
3. Set up the VPN 
4. Migrate the EC2 instance to GCE

The solution architecture is roughly like this:
[ Insert architecture diagram ]


## Develop
This demo uses _Docker_ to create a _Tools_ image with all the dependencies required:
* aws_cli
* gcloud
* terraform

The make file on the repo will set up everything for you, the only local dependency that you need is **Docker**.

### PREPARATION
There is a bit of preparation in both AWS and GCP. Please folow these instructions carefully.

**AWS**

1. Obtain your aws `key-id` and `key-secret` as explained [here](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) and load them in environment variables:
```bash
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

2. Generate a **ssh key pair** and take note of the public key. **Store the private key in a safe place and DON'T COMMIT IT**. These keys are going to be used to ssh into the EC2 instances. You can use keygen for this:
```bash
ssh-keygen -t rsa -C "your_email@example.com"
```
3. Update the `aws/variables.tfvars` file and add the path to the public key: 
```properties
...
public_key_path = <Path to your public key>
...
```

**GCP**

1. Create a GCP project and a service account with `Editor` role as explained [here.](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account)

2. Create a key file for that service account in `json` format. **Store this file in a safe place and DON'T COMMIT IT**. Instructions [here.](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys)

3. Export the location of the file to an environment variable:
```
export GCLOUD_KEYFILE_JSON=<FULL PATH OF YOUR FILE>
```

4. Enable the `compute` api as shown [here](https://cloud.google.com/apis/docs/enable-disable-apis). Enter `compute engine api` in the search box to find it.


### DEPLOYING THE CODE

Run `make help` for detailed instructions.

For a fresh project run:
```bash
make init
make plan
make apply
...
make destroy
```

These will install all resources in both GCP and AWS.

Open the browser and navigate to the `lb_eip` url printed in the console after the aws terraform apply.

## Connecting to the EC2 instances

To connect to the bastion host, follow this steps:
1. Obtain the dns name of the bastion host and the private ip of the instance you want to connect. These are printed in the console after running `make apply`.
2. Add the private key to the ssh-agent: `$ ssh-add -k <private_key_path>`
3. Access the bastion host with ssh-agent forward: `ssh -A ubuntu@<bastion-host-elastic-ip>`
4. Access any private instance such as the web servers once you are inside the bastion host: `ssh ubuntu@<ip of the private ec2 instance>`


## Acknowledgements

Based on:
* Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
* Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app
