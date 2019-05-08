# terraform-aws-hosted-wordpress
A terraform project to install as AWS hosted wordpress site

Be sure to load your aws account environment variables:
```
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

Run on mac from this dir:
`make run`
This will ssh into the docker image.

Inside the image 
Firs time run: `terraform init` to install the aws provider.

run:
`terraform plan -var-file=variables.tfvars -out terraform.plan`

and then:
`terraform apply terraform.plan`

to destroy
`terraform destroy -var-file=variables.tfvars`

Based on:
http://architecture.ginocoates.com/2017/01/01/terraforming-wordpress-on-aws/


Other articles of interest:
Video: https://www.youtube.com/watch?v=pdb9Q6V0WZo
Code: https://github.com/Stratoscale/strato-aws-examples/tree/master/terraform/wordpress-3tier-app
