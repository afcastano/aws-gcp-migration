# pass the region as a variable so we can provide it in a tfvars file
variable "gcp_region" {}
variable "gcp_projectId" {}

variable gcp_instance_type {
  description = "Machine Type. Correlates to an network egress cap."
  default = "n1-highmem-8"
}

variable gcp_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
}

variable gcp_subnet1_cidr {
  default = "10.240.0.0/24"
}

variable gcp_vm_address {
  description = "Private IP address for GCP VM instance."
  default = "10.240.0.100"
}

variable "gcp_terraform_sa" {
  default = "/root/.gcp/terraform_sa.json"
}