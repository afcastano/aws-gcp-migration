**AWS**

1. Obtain your aws `key-id` and `key-secret` as explained [here](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)

2. Load them in environment variables:

```bash
export AWS_ACCESS_KEY_ID=<YOUR KEY ID>
export AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRET>
export AWS_DEFAULT_REGION=ap-southeast-2
```

**GCP**

1. Create a GCP project and a service account with `Owner` role as explained [here.](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account).

2. Create a key file for that service account in `json` format. **Store this file in a safe place and DON'T COMMIT IT**. Instructions [here.](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys)

3. Export the location of the file to an environment variable:
```bash
export GCLOUD_KEYFILE_JSON=<FULL PATH OF YOUR FILE>
```

4. Make sure that the folowing APIs are enabled ( Instructions [here](https://cloud.google.com/apis/docs/enable-disable-apis) ) : 
    - `serviceusage.googleapis.com`
    - `cloudresourcemanager.googleapis.com` 
    - `compute.googleapis.com`
