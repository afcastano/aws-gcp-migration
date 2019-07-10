provider "aws" {
  profile = "default"
  region  = "${var.aws_region}"
}

provider "tls" {
}

provider "google" {
  credentials = "${file("${var.gcp_terraform_sa}")}"
  region      = "${var.gcp_region}"
  project     = "${var.gcp_projectId}"
}

/*
 * Terraform compute resources for GCP.
 * Acquire all zones and choose one randomly.
 */
data "google_compute_zones" "available" {
  region = "${var.gcp_region}"
}

module "aws_wordpress" {
    source = "./modules/aws_wordpress"

    availability_zone = "${var.aws_availability_zone}"
}

module "gcp_target" {
  source = "./modules/gcp_target"

  region = "${var.gcp_region}"
  zone = "${data.google_compute_zones.available.names[0]}"
  projectId = "${var.gcp_projectId}"
  instance_type = "${var.gcp_instance_type}"
  
}