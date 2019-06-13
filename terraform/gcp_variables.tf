# pass the region as a variable so we can provide it in a tfvars file
variable "gcp_region" {}
variable "gcp_projectId" {}

variable gcp_instance_type {
  description = "Machine Type. Correlates to an network egress cap."
  default = "n1-standard-2"
}

variable gcp_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
}

variable gcp_public_cidr {
  default = "10.240.0.0/24"
}
variable gcp_workload_cidr {
  default = "10.240.1.0/24"
}

variable gcp_velostrata_cidr {
  default = "10.240.3.0/24"
}

variable "gcp_terraform_sa" {
  default = "/root/.gcp/terraform_sa.json"
}

variable GCP_TUN1_VPN_GW_ASN {
  description = "Tunnel 1 - Virtual Private Gateway ASN, from the AWS VPN Customer Gateway Configuration"
  default = "64512"
}

variable GCP_TUN1_CUSTOMER_GW_INSIDE_NETWORK_CIDR {
  description = "Tunnel 1 - Customer Gateway from Inside IP Address CIDR block, from AWS VPN Customer Gateway Configuration"
  default = "30"
}

variable GCP_TUN2_VPN_GW_ASN {
  description = "Tunnel 2 - Virtual Private Gateway ASN, from the AWS VPN Customer Gateway Configuration"
  default = "64512"
}

variable GCP_TUN2_CUSTOMER_GW_INSIDE_NETWORK_CIDR {
  description = "Tunnel 2 - Customer Gateway from Inside IP Address CIDR block, from AWS VPN Customer Gateway Configuration"
  default = "30"
}

variable gcp_velostrata_api_password {
  default = "wpdemo1234"
}

variable gcp_velostrata_enc_key {
  default = "wpdemo1234"
}
