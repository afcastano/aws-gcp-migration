# Migrate WordPress from AWS to GCP using Migrate for GCE (Velostrata)

Use terraform to deploy a 3-tier WordPress application in AWS and migrate it to GCP using [Migrate for GCE (Velostrata)](https://cloud.google.com/migrate/compute-engine/docs/4.5/).

Check out this tutorial with the step-by-step guide of each of the parts involved on this demo. (Pending link)

Please look at the [Troubleshooting](docs/TROUBLE_SHOOTING.md) guide if you can't get this working.

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

The deployed solution will look like this:

[INSERT DIAGRAM]()

---
These are the [References](docs/ACKNOWLEDGEMENTS.md) on which I based this demo.