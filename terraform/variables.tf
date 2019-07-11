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
