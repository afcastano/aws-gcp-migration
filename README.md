# Migrate WordPress from AWS to GCP using velostrata

```
**WORK IN PROGRESS**
```

Use terraform to deploy a 3-tier WordPress application in AWS and migrate it to GCP using Velostrata.

This project serves two purposes:
- A demo to present the working solution.
- A tutorial explaining the different steps and concepts to set up and migrate a Word Press application.

## How to run the demo
There is some set up needed in both clouds detailed [here](docs/demo/PRE-REQUISITES.md). Summary:
- Install Docker (The only local dependency)
- AWS: Obtain a key id and secret
- GCP: Create a json key file and enable APIs
- Load keys into environment variables

### Steps:
1. Deploy: `make deploy`
2. Accept velostrata eula: `make eula`
3. Open and configure wordpress in aws: `make wp_aws`
4. Run migration: `make velostrata_migrate`
5. Open wordpress in gcp: `make wp_gcp`
6. Clean up resources: `make destroy`

## Tutorial contents
1. [How to deploy a WordPress 3 tier application in AWS](docs/tutorial/TUTORIAL.md)
2. [How to deploy a high availability VPN between GCP and AWS](docs/tutorial/TUTORIAL.md)
3. [How to migrate Tier 2 from AWS to GCP](docs/tutorial/TUTORIAL.md)
4. [How to set up an external load balancer in GCP for balancing trafic between the migrated instances](docs/tutorial/TUTORIAL.md)

**Please take a look at the [Security notes](docs/SECURITY_NOTES.md) before trying this for production.**

Also there is a small [Troubleshooting](docs/TROUBLE_SHOOTING) guide and some [Acknowledgements](docs/ACKNOELEDGEMENTS.md)
