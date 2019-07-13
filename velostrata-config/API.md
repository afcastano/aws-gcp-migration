
Create cloud credentials
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@aws-credentials.json" https://35.189.9.60/velostrata/api/v42/cloud/credentials/aws2
```

Create target cloud details
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@aws-cloud-details.json" https://35.189.9.60/velostrata/api/v42/cloud/details
```
