{
    "_type": "CreateGcpCloudExtensionRequest",
    "ceSize": "Small",
    "name": "ce",
    "workloadDefaultSubnetId": "${gcp_workload_subnet_id}",
    "licenseType": "VelostrataIssued",
    "primaryFrontendZone": "${gcp_region}-a",
    "secondaryFrontendZone": "${gcp_region}-a",
    "primaryFrontendSubnetId": "${ce_subnet_id}",
    "secondaryFrontendSubnetId": "${ce_subnet_id}",
    "infraProjectId": "${gcp_project_id}",
    "defaultInstanceServiceAccountId": "velos-workload@aws-gcp-migration-demo.iam.gserviceaccount.com",
    "cloudEdgeServiceAccountId": "velos-cloud-extension@aws-gcp-migration-demo.iam.gserviceaccount.com",
    "infraNetworkTags": ["fw-velostrata"],
    "workloadDefaultNetworkTags": ["fw-workload"],
    "defaultInstanceProjectId": "${gcp_project_id}"
}