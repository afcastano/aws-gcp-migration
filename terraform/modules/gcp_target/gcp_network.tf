resource "google_compute_subnetwork" "public-subnet" {
  name                     = "public-subnet"
  ip_cidr_range            = "${var.gcp_public_cidr}"
  project                  = "${var.projectId}"
  region                   = "${var.region}"
  network                  = "${google_compute_network.demo-vpc.self_link}"
  enable_flow_logs         = true
}

resource "google_compute_network" "demo-vpc" {
  name                    = "demo-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  project                 = "${var.projectId}"
}