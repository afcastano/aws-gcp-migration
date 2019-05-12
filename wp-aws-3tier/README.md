# terraform-aws-hosted-wordpress
A terraform project to install a 3-tier Wordpress applicaiton in AWS. The only dependency required is **DOCKER**.

The architecture is roughly like this:
<Insert architecture diagram>


# Development

The only required local dependency is Docker. 

**PREPARATION**

1. Create the `aws-terraform` image locally by running:
```
cd ../images/aws-terraform
make build
```

2. Be sure to load your aws account environment variables:
```
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

3. Generate a key pair and take note of the public key. **Store the private key in a safe place**. These keys are going to be used to ssh into the EC2 instances. You can use keygen for this:
```
ssh-keygen -t rsa -C "your_email@example.com"
```

4. Update the `variables.tfvars` file and add the path to the public key: `public_key_path = <Path to your public key>`

**Deploying WordPress**

Come back to this folder and run `make help` for a list of commands.

Normal usage:
```
make init
make plan
make apply
...
make destroy
```

Open the browser and navigate to the lb_eip url printed in the console after `make apply`

**Connecting to the EC2 instances**

To connect to the bastion host, follow this steps:
1. Obtain the dns name of the bastion host and the private ip of the instance you want to connect. These are printed in the console after running the terraform plan.
2. Add the private key to the ssh-agent: `$ ssh-add -k <private_key_path>`
3. Access the bastion host with ssh-agent forward: `ssh -A ubuntu@<bastion-host-elastic-ip>`
4. Access any private instance such as the web servers: `ssh ubuntu@<ip of the private ec2 instance>`


**Acknowledgements**

Based on:
* Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
* Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app
