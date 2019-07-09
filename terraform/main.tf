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

module "aws_wordpress" {
    source = "./modules/aws_wordpress"

    availability_zone = "${var.aws_availability_zone}"
}
