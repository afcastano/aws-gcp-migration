provider "aws" {
  profile = "default"
  region  = "${var.aws_region}"
}

provider "google" {
  credentials = "${file("${var.gcp_terraform_sa}")}"
  region      = "${var.gcp_region}"
  project     = "${var.gcp_projectId}"
}
