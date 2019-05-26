resource "google_compute_subnetwork" "demo-subnet" {
  name                     = "demo-subnet"
  ip_cidr_range            = "${var.gcp_subnet1_cidr}"
  project                  = "${var.gcp_projectId}"
  region                   = "${var.gcp_region}"
  network                  = "${google_compute_network.demo-vpc.self_link}"
  enable_flow_logs         = true
}

resource "google_compute_network" "demo-vpc" {
  name                    = "demo-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  project                 = "${var.gcp_projectId}"
}