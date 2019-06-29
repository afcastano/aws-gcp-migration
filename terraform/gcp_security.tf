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

# Allow access to workload instances from public internet.
resource "google_compute_firewall" "gcp-workload-ingress-ssh-public" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-workload-ingress-ssh-public"
  network = "${google_compute_network.demo-vpc.name}"

  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_workload_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Velostrata firewall rules
# Ref: https://cloud.google.com/velostrata/docs/concepts/planning-a-migration/network-access-requirements


# Allow access from internet to velostrata manager.
resource "google_compute_firewall" "gcp-velostrata-manager-ingress-https-grpc" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velostrata-manager-ingress-https-grpc"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_manager_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "gcp-velos-ce-control" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velos-ce-control"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}