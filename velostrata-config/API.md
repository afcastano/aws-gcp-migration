
Create cloud credentials
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@aws-credentials.json" https://35.201.21.241/velostrata/api/v42/cloud/credentials/aws
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

Generate run book
```
curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@generate-runbook.json" -O -J  https://35.201.21.241/auto/rest/runbooks
```

Update Runbook
```bash
awk -F, -v OFS=, 'NR==2{$1="1"; $15="n1-standard-4"; $20="true"}{print}' Velostrata_Runbook.csv > out/runbook.csv
```

Create wave with runbook
```bash
curl -k --user apiuser:wpdemo1234 -H "Content-Type: text/csv" -X PUT -d @out/runbook.csv https://35.201.21.241/auto/rest/waves/w1
```
