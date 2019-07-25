/*
 * Terraform security (firewall) resources for GCP.
 */


# Allow PING testing and ssh to the bastion instances.
resource "google_compute_firewall" "gcp-bastion-all" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-public-ingress-icmp-ssh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "bastion",
    "wp"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow egess to aws network.
resource "google_compute_firewall" "gcp-allow-vpn" {
  name    = "${google_compute_network.demo-vpc.name}-cp-allow-vpn"
  network = "${google_compute_network.demo-vpc.name}"

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  target_tags = [
    "bastion",
    "wp",
    "fw-velostrata",
    "fw-velosmanager"
  ]

  destination_ranges = [
    "172.16.0.0/16"
  ]
}