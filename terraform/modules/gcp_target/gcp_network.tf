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
resource "google_compute_instance_group" "wp-group" {
  name        = "wp-group"
  zone        = "${data.google_compute_zones.available.names[0]}"
  network     = "${google_compute_network.demo-vpc.self_link}"
  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_health_check" "wp-check" {
  name               = "wp-check"
  http_health_check {
    request_path       = "/wp-login.php"
    port              = 80

  }
  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_backend_service" "wp-backend" {
  provider = "google-beta"

  name          = "wp-backend"
  health_checks = ["${google_compute_health_check.wp-check.self_link}"]
  backend {
    group = "${google_compute_instance_group.wp-group.self_link}"
  }
  connection_draining_timeout_sec = 10
}

resource "google_compute_url_map" "wp-map" {
  name        = "wp-map"
  default_service = "${google_compute_backend_service.wp-backend.self_link}"
}

resource "google_compute_target_http_proxy" "wp-proxy" {
  name        = "wp-proxy"
  url_map     = "${google_compute_url_map.wp-map.self_link}"
}

resource "google_compute_global_forwarding_rule" "wp-lb" {
  name       = "wp-lb"
  target     = "${google_compute_target_http_proxy.wp-proxy.self_link}"
  port_range = "80"
}