provider "aws" {
  profile = "default"
  region  = "${var.aws_region}"
}

provider "tls" {
}

provider "google-beta" {
  credentials = "${file("${var.gcp_terraform_sa}")}"
  region      = "${var.gcp_region}"
  project     = "${var.gcp_projectId}"
}

provider "google" {
  credentials = "${file("${var.gcp_terraform_sa}")}"
  region      = "${var.gcp_region}"
  project     = "${var.gcp_projectId}"
}

provider "null" {
}

module "aws_wordpress" {
    source = "./modules/aws_wordpress"
    gcp_wp_subnet = "${var.gcp_private_cidr}"
    gcp_public_subnet = "${var.gcp_public_cidr}"
}

module "gcp_target" {
  source = "./modules/gcp_target"

  region = "${var.gcp_region}"
  projectId = "${var.gcp_projectId}"
  instance_type = "${var.gcp_instance_type}"
  gcp_public_cidr = "${var.gcp_public_cidr}"
  gcp_private_cidr = "${var.gcp_private_cidr}"
}

module "aws_gcp_vpn" {
  source = "./modules/aws_gcp_vpn"
  aws_vpc_id = "${module.aws_wordpress.vpc_id}"
  wp_route_table_id = "${module.aws_wordpress.wp_route_table_id}"
  db_route_table_id = "${module.aws_wordpress.db_route_table_id}"
  gcp_region = "${var.gcp_region}"
  gcp_vpc_name = "${module.gcp_target.vpc_name}"

}

module "velostrata" {
  source = "./modules/velostrata"
  
  aws_vpc_id = "${module.aws_wordpress.vpc_id}"
  gcp_projectId = "${var.gcp_projectId}"
  gcp_vpc_name = "${module.gcp_target.vpc_name}"
  gcp_zone = "${module.gcp_target.bastion_zone}"
  gcp_velos_manager_subnet = "${module.gcp_target.public_subnet_name}"
  gcp_instance_type = "${var.gcp_instance_type}"

}