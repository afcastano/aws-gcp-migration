{
    "credentialsId": {
      "_type": "CredentialsId",
      "value": "aws"
    },
    "name": "aws",
    "_type": "AwsCloudDetails",
    "availabilityZoneToSubnet": {
      "_type": "StringToObjectMap",
      "${aws_availability_zone}": "${aws_subnet}"
    },
    "region": "${aws_region}",
    "securityGroupIds": [
      "${security_group}"
    ]
  }