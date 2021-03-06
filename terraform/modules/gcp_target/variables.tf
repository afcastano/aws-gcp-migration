# pass the region as a variable so we can provide it in a tfvars file
variable "region" {}
variable "projectId" {}

variable instance_type {}

variable gcp_private_cidr {}

variable gcp_public_cidr {}

variable gcp_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
}