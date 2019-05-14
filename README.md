THIS IS WORK IN PROGRES
===========================================

# Migrate AWS application to GCP

Demo: 

1. Deploy a 3 tier WordPress application in in AWS
2. Create a GCP project. 
3. Set up the VPN 
4. Migrate the EC2 instance to GCE

The solution architecture is roughly like this:
[ Insert architecture diagram ]


## Develop

The only local dependency that you need is **Docker**.


**PREPARATION**

1. Obtain your aws key id and key secrets and load them in environment variables:
```
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

2. Generate a ssh key pair and take note of the public key. **Store the private key in a safe place and DON'T COMMIT IT**. These keys are going to be used to ssh into the EC2 instances. You can use keygen for this:
```
ssh-keygen -t rsa -C "your_email@example.com"
```

3. Update the `wp-aws-3tier/variables.tfvars` file and add the path to the public key: `public_key_path = <Path to your public key>`

**DEPLOYING WORDPRESS**

Run `make help` for detailed instructions.

For a fresh project run:
```
make init
make plan
make apply
...
make destroy
```
Open the browser and navigate to the `lb_eip` url printed in the console after `make apply`

## Connecting to the EC2 instances

To connect to the bastion host, follow this steps:
1. Obtain the dns name of the bastion host and the private ip of the instance you want to connect. These are printed in the console after running the terraform plan.
2. Add the private key to the ssh-agent: `$ ssh-add -k <private_key_path>`
3. Access the bastion host with ssh-agent forward: `ssh -A ubuntu@<bastion-host-elastic-ip>`
4. Access any private instance such as the web servers once you are inside the bastion host: `ssh ubuntu@<ip of the private ec2 instance>`


## Acknowledgements

Based on:
* Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
* Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app
