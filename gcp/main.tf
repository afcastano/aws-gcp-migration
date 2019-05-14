provider "google" {
  credentials = "${file("${var.terraform_sa}")}"
  region      = "${var.region}"
  project     = "${var.projectId}"
}