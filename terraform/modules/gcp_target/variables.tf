# pass the region as a variable so we can provide it in a tfvars file
variable "region" {}
variable "projectId" {}

variable instance_type {}

variable gcp_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
}

variable gcp_public_cidr {
  default = "10.240.0.0/24"
}
variable gcp_private_cidr {
  default = "10.240.1.0/28"
}

variable gcp_velostrata_cidr {
  default = "10.240.3.0/24"
}
