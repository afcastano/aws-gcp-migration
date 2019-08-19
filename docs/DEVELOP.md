## Velostrata deb packages
Look for them here:
https://storage.googleapis.com/velostrata-release

## Velostrata manager image
Print the access token
```
gcloud auth print-access-token
```
Look for the image in the result of:
```
curl -s \
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer <Access_TOKEN>' \
https://www.googleapis.com/compute/v1/projects/click-to-deploy-images/global/images?filter=name%3Dvelostrata*
```