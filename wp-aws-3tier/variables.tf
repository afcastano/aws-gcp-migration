# pass the region as a variable so we can provide it in a tfvars file
variable "region" {
  type = "string"
}
variable "zones" {
  type = "map"

  default = {
    "ap-southeast-2" = "ap-southeast-2a"
  }
}

variable "web_number" {}
variable "web_ami" {}
variable "web_instance_type" {}
variable "public_key_path" {}
variable "public_key_name" {}

# Database variables
variable "db_password" {}
variable "db_user" {}

variable "availability_zone_1" {}
variable "availability_zone_2" {}