/*
 * Terraform security (firewall) resources for GCP.
 */

# Allow PING testing.
resource "google_compute_firewall" "gcp-allow-icmp" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-allow-icmp"
  network = "${google_compute_network.demo-vpc.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow SSH 
resource "google_compute_firewall" "gcp-allow-ssh" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-allow-ssh"
  network = "${google_compute_network.demo-vpc.name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow TCP traffic from the Internet.
resource "google_compute_firewall" "gcp-allow-internet" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-allow-internet"
  network = "${google_compute_network.demo-vpc.name}"

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}
