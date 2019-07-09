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
variable aws_network_cidr {
  description = "VPC network ip block."
  default = "172.16.0.0/16"
}

variable aws_pub_subnet_1_cidr {
  default = "172.16.5.0/24"
}

variable "availability_zone" {}