# pass the region as a variable so we can provide it in a tfvars file
variable "aws_region" {
  type = "string"
}
variable "aws_wp_server_count" {
  type = "string"
  default = "2"
}

# Use Public Xenial cloud image ami
# Recommend use of Xenial's latest cloud image
# located here: https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
# Search for an ami here: https://cloud-images.ubuntu.com/locator/ec2/
variable "aws_ubuntu_ami" {
  type = "string"
  default = "ami-0bab153cd7bd6fb18" # ap-southeast-1
}
variable "aws_instance_type" {
  type = "string"
  default = "t2.medium"
}
variable "aws_public_key_path" {}
variable "aws_public_key_name" {
  type = "string"
  default = "wp_demo"
}

# Database variables
variable "aws_wp_db_password" {}
variable "aws_wp_db_user" {}

variable "aws_availability_zone_1" {}
variable "aws_availability_zone_2" {}