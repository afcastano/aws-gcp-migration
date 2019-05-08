# define the local IP to map to the SSH security rule
variable "local_ip" {
  type = "string"
}

# pass the region as a variable so we can provide it in a tfvars file
variable "region" {
  type = "string"
}

# AWS key name
variable "ssh_key_name" {}

# define the region specific wordpress images
variable "wordpress-images" {
  type = "map"

  default = {
    "ap-southeast-2" = "ami-01724ec0278348e0a"
  }
}

variable "zones" {
  type = "map"

  default = {
    "ap-southeast-2" = "ap-southeast-2a"
  }
}
