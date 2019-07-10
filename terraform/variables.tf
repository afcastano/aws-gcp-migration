# pass the region as a variable so we can provide it in a tfvars file
variable "aws_region" {
}
variable "aws_availability_zone" {}
variable "gcp_region" {}
variable "gcp_projectId" {}

variable "gcp_terraform_sa" {
  default = "/root/.gcp/terraform_sa.json"
}

variable "gcp_velostrata_extension_tag" {
  default = "fw-velostrata"
}

variable "gcp_velostrata_manager_tag" {
  default = "fw-velosmanager"
}

variable "gcp_velostrata_workload_tag" {
  default = "fw-workload"
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

variable gcp_instance_type {
  description = "Machine Type. Correlates to an network egress cap."
  default = "n1-standard-2"
}
