variable gcp_wp_subnet {
  description = "GCP subnet over the vpn"
}

variable aws_disk_image {
  description = "Boot disk for gcp_instance_type."
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

variable "aws_instance_type" {
  type = "string"
  default = "t2.medium"
}

variable aws_network_cidr {
  description = "VPC network ip block."
  default = "172.16.0.0/16"
}

variable aws_pub_subnet_1_cidr {
  default = "172.16.5.0/24"
}

variable aws_pub_subnet_2_cidr {
  default = "172.16.6.0/24"
}

variable aws_wp_subnet_cidr {
  default = "172.16.4.0/24"
}

variable aws_db_subnet_1_cidr {
  default = "172.16.1.0/24"
}

variable aws_db_subnet_2_cidr {
  default = "172.16.2.0/24"
}

variable aws_wp_db_password {
  default = "wpdb1234"
}

variable aws_wp_db_user {
  default = "admin"
}