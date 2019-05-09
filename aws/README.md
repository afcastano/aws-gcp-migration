# terraform-aws-hosted-wordpress
A terraform project to install Wordpress in AWS EC2.

The only dependency required is **DOCKER**.

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

**Deploying WordPress**

Run `make help` for a list of commands.

Normal usage:
```
make init
make plan
make apply
...
make destroy
```

**Acknowledgements**

Based on:
http://architecture.ginocoates.com/2017/01/01/terraforming-wordpress-on-aws/


Other articles of interest:
Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app
