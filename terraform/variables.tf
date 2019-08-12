# pass the region as a variable so we can provide it in a tfvars file
variable "aws_region" {
}
variable "gcp_region" {}
variable "gcp_projectId" {}

variable "gcp_terraform_sa" {
  default = "/root/.gcp/terraform_sa.json"
}

variable gcp_instance_type {
  description = "Machine Type. Correlates to an network egress cap."
  default = "n1-standard-2"
}

variable gcp_public_cidr {
  default = "10.240.0.0/24"
}

variable gcp_private_cidr {
  default = "10.240.1.0/28"
}
