resource "google_compute_subnetwork" "public-subnet" {
  name                     = "public-subnet"
  ip_cidr_range            = "${var.gcp_public_cidr}"
  project                  = "${var.projectId}"
  region                   = "${var.region}"
  network                  = "${google_compute_network.demo-vpc.self_link}"
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "private-subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "${var.gcp_private_cidr}"
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

####LOAD BALANCER
resource "google_compute_target_pool" "wp-pool" {
  name = "wp-pool"

  instances = [
    "${data.google_compute_zones.available.names[0]}/wp-server-0",
    "${data.google_compute_zones.available.names[0]}/wp-server-1",
  ]

  health_checks = [
    "${google_compute_http_health_check.wp-check.name}",
  ]
}

resource "google_compute_http_health_check" "wp-check" {
  name               = "wp-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_forwarding_rule" "wp-lb" {
  name       = "wp-lb"
  target     = "${google_compute_target_pool.wp-pool.self_link}"
  port_range = "80"
  load_balancing_scheme = "EXTERNAL"
}