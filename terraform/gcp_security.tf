/*
 * Terraform security (firewall) resources for GCP.
 */


# Allow PING testing and ssh to the bastion instances.
resource "google_compute_firewall" "gcp-bastion-ingress-icmp-ssh" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-public-ingress-icmp-ssh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  target_tags = [
    "bastion"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# Allow access to workload instances from bastion only.
resource "google_compute_firewall" "gcp-private-ingress-icmp-https-ssh" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-private-ingress-icmp-https-ssh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443"]
  }

  target_tags = [
    "${var.gcp_velostrata_workload_tag}"
  ]

  source_tags = [
    "bastion"
  ]
}

# Velostrata firewall rules
# Ref: https://cloud.google.com/velostrata/docs/concepts/planning-a-migration/network-access-requirements


# Allow access from internet to velostrata manager.
resource "google_compute_firewall" "gcp-velostrata-manager-ingress-https-grpc" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velostrata-manager-ingress-https-grpc"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["443", "9119", "22"]
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
    protocol = "tcp"
    ports = ["443", "9111"]
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_tags = [
    "${var.gcp_velostrata_manager_tag}"
  ]
}

resource "google_compute_firewall" "gcp-velos-ssh-from-internet" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velos-ssh-from-internet"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "gcp-velos-backend-control" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velos-backend-control"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["9119"]
  }

  target_tags = [
    "${var.gcp_velostrata_manager_tag}"
  ]

  source_ranges = [
    "${var.aws_network_cidr}"
  ]
}

resource "google_compute_firewall" "gcp-velos-ce-backend" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velos-ce-backend"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["9111"]
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_ranges = [
    "${var.aws_network_cidr}"
  ]
}

resource "google_compute_firewall" "gcp-workload-ingress-rdp-ssh" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-workload-ingress-rdp-ssh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["22", "3389"]
  }

  target_tags = [
    "${var.gcp_velostrata_workload_tag}"
  ]

  source_tags = [
    "${var.gcp_velostrata_manager_tag}"
  ]
}

resource "google_compute_firewall" "gcp-velostrata-ingress-iscsi-ssh" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velostrata-ingress-iscsi-shh"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "tcp"
    ports = ["22", "3260"]
  }

  allow {
    protocol = "udp"
    ports = ["514"]
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_tags = [
    "${var.gcp_velostrata_workload_tag}"
  ]
}

resource "google_compute_firewall" "gcp-velostrata-extension-all" {
  name    = "${google_compute_network.demo-vpc.name}-gcp-velostrata-extension-all"
  network = "${google_compute_network.demo-vpc.name}"


  allow {
    protocol = "all"
  }

  target_tags = [
    "${var.gcp_velostrata_extension_tag}"
  ]

  source_tags = [
    "${var.gcp_velostrata_extension_tag}",
    "bastion"
  ]
}