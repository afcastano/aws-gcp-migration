# DEMO Terraform Wordpress in AWS with VPN to GCP

Demo steps:

1. Deploy a 3 tier WordPress application in in AWS
2. Create a GCP project. 
3. Set up the VPN 

The solution architecture is roughly like this:
[ Insert architecture diagram ]


## Develop
This demo uses _Docker_ to create an image with all the local dependencies required:
* aws_cli
* gcloud
* terraform

The make file on the repo will set up everything for you, the only local dependency that you need is **Docker**.

### PREPARATION
There is a bit of preparation in both AWS and GCP. Please folow these instructions carefully.

**AWS**

1. Obtain your aws `key-id` and `key-secret` as explained [here](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)

2. Load them in environment variables:

```bash
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

**GCP**

1. Create a GCP project and a service account with `Editor` role as explained [here.](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account)

2. Create a key file for that service account in `json` format. **Store this file in a safe place and DON'T COMMIT IT**. Instructions [here.](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys)

3. Export the location of the file to an environment variable:
```bash
export GCLOUD_KEYFILE_JSON=<FULL PATH OF YOUR FILE>
```

4. Enable the `compute` api as shown [here](https://cloud.google.com/apis/docs/enable-disable-apis). Enter `compute engine api` in the search box to find it.


### DEPLOYING THE CODE

Clone this repo and run `make help` for detailed instructions.

For a fresh project run:
```bash
cd terraform
make init
make plan
make apply
...
make destroy
```

These will install all resources in both GCP and AWS.

Open the browser and navigate to the `AWS wordpress external url` printed in the console after the aws terraform apply.

## Connecting to the EC2 instances

To connect to the bastion host, follow this steps:
1. Obtain the dns name of the bastion host and the private ip of the instance you want to connect. These are printed in the console after running `make apply`.
2. Access the bastion host with user: `demo`: `ssh demo@<bastion-host-elastic-ip>`. Password is also `demo`
4. Access any private instance such as the web servers once you are inside the bastion host: `ssh demo@<ip of the private ec2 instance>`

## Connecting to the GCP instance
1. Obtain the ip of the public ip gcp bastion host in the output of the `make apply` command.
2. Run `ssh gcp@<bastion public ip>`. Password is `gcp`.

## Testing the VPN 
### GCP -> AWS
1. Connecto to the GCP instance as per previous point
2. Navigate to the instance without public ip by doing `ssh gcp@<gcp private instance ip>`. Passowrd is `gcp`
2. ssh into the private ip of the wp servers. Find the ip in the output of the `make apply` command under the name: `AWS wp-server private ips`. Then do `ssh demo@<wp-private-ip>`. Password is `demo`. 

Now you have connected from a private GCP VM to a private AWS vm using a VPN.

## Acknowledgements

Based on:
* Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
* Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app

GCP VPN:
* https://cloud.google.com/solutions/automated-network-deployment-multicloud
