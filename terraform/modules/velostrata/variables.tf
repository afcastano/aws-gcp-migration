variable "aws_vpc_id" {}
variable "gcp_projectId" {}

variable gcp_zone {}

variable gcp_instance_type {}

variable "gcp_velos_manager_subnet" {}

variable "gcp_vpc_name" {}

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
