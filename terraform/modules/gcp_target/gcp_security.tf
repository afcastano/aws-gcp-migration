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
    "bastion"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}