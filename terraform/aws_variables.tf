variable "aws_wp_server_count" {
  type = "string"
  default = "2"
}

# Use Public Xenial cloud image ami
# Recommend use of Xenial's latest cloud image
# located here: https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
# Search for an ami here: https://cloud-images.ubuntu.com/locator/ec2/
variable aws_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

variable "aws_instance_type" {
  type = "string"
  default = "t2.medium"
}

# Network variables #######
# variable aws_network_cidr {
#   description = "VPC network ip block."
#   default = "172.16.0.0/16"
# }

# variable aws_subnet1_cidr {
#   description = "Subset block from VPC network ip block."
#   default = "172.16.0.0/24"
# }

# variable aws_vm_address {
#   description = "Private IP address for AWS VM instance."
#   default = "172.16.0.100"
# }

# Database variables
variable "aws_wp_db_password" {
  type = "string"
  default = "Stratoscale!Orchestration!"
}
variable "aws_wp_db_user" {
  type = "string"
  default = "admin"
}

# pass the region as a variable so we can provide it in a tfvars file
variable "aws_region" {
  type = "string"
}

variable "aws_availability_zone_1" {}
variable "aws_availability_zone_2" {}