
Create cloud credentials
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@aws-credentials.json" https://35.201.21.241/velostrata/api/v42/cloud/credentials/aws2
```

Create target cloud details
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@aws-cloud-details.json" https://35.201.21.241/velostrata/api/v42/cloud/details
```

Create cloud extensions
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@cloud-extensions.json" https://35.201.21.241/velostrata/api/v42/cloudextensions
```

Get task
```
curl -k --user apiuser:wpdemo1234 https://35.201.21.241/velostrata/api/v42/tasks/t-4
```