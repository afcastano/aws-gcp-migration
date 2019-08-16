# Migrate WordPress from AWS to GCP using velostrata

Use terraform to deploy a 3-tier WordPress application in AWS and migrate it to GCP using Velostrata.

This project serves two purposes:
- A demo to present the working solution.
- A set of tutorials guiding how to independently set up the diferent parts of this solution.

## Demo
There is some set up needed in both clouds, please read the [PRE-REQUISITES](docs/demo/PRE-REQUISITES.md) doc for more info.  
**Summary:**
- Install Docker (The only local dependency)
- AWS: Obtain a key id and secret
- GCP: Create a json key file and enable some APIs
- Load keys into environment variables

**Steps:**
1. Deploy: `make deploy`
2. Open and configure wordpress in aws: `make wp_aws`
3. Accept velostrata eula: `make eula`
4. Run migration: `make velostrata_migrate`
5. Open wordpress in gcp: `make wp_gcp`
6. Clean up resources: `make destroy`

## Tutorial
There are three tutorials that can be followed, each of them builds up on what was developed in the previous one:

1. [How to deploy a WordPress 3 tier application in AWS](docs/tutorial/TUTORIAL.md)
2. [How to deploy a high availability VPN between GCP and AWS](docs/tutorial/TUTORIAL.md)
3. [How to migrate EC2 instances from AWS to GCP using velostrata](docs/tutorial/TUTORIAL.md)

**Please take a look at the [Security notes](docs/SECURITY_NOTES.md) before trying this for production.**

Also there is a small [Troubleshooting](docs/TROUBLE_SHOOTING.md) guide and some [Acknowledgements](docs/ACKNOWLEDGEMENTS.md)
