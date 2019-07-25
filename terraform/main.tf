provider "aws" {
  profile = "default"
  region  = "${var.aws_region}"
}

provider "tls" {
}

# provider "google" {
#   credentials = "${file("${var.gcp_terraform_sa}")}"
#   region      = "${var.gcp_region}"
#   project     = "${var.gcp_projectId}"
# }

provider "null" {
}


/*
 * Terraform compute resources for GCP.
 * Acquire all zones and choose one randomly.
 */
# data "google_compute_zones" "available" {
#   region = "${var.gcp_region}"
# }

module "aws_wordpress" {
    source = "./modules/aws_wordpress"
}

# module "gcp_target" {
#   source = "./modules/gcp_target"

#   region = "${var.gcp_region}"
#   zone = "${data.google_compute_zones.available.names[0]}"
#   projectId = "${var.gcp_projectId}"
#   instance_type = "${var.gcp_instance_type}"
  
# }

# module "aws_gcp_vpn" {
#   source = "./modules/aws_gcp_vpn"
#   aws_vpc_id = "${module.aws_wordpress.vpc_id}"
#   aws_route_table_id = "${module.aws_wordpress.route_table_id}"
#   aws_igw_id = "${module.aws_wordpress.igw_id}"
#   gcp_region = "${var.gcp_region}"
#   gcp_vpc_name = "${module.gcp_target.vpc_name}"

# }

# module "velostrata" {
#   source = "./modules/velostrata"
  
#   aws_vpc_id = "${module.aws_wordpress.vpc_id}"
#   gcp_projectId = "${var.gcp_projectId}"
#   gcp_vpc_name = "${module.gcp_target.vpc_name}"
#   gcp_zone = "${data.google_compute_zones.available.names[0]}"
#   gcp_velos_manager_subnet = "${module.gcp_target.public_subnet_name}"
#   gcp_instance_type = "${var.gcp_instance_type}"

# }