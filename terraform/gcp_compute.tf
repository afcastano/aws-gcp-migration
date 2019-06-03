/*
 * Terraform compute resources for GCP.
 * Acquire all zones and choose one randomly.
 */

data "google_compute_zones" "available" {
  region = "${var.gcp_region}"
}

resource "google_compute_address" "gcp-ip" {
  name = "gcp-vm-ip-${var.gcp_region}"
  region = "${var.gcp_region}"
}

resource "google_compute_instance" "gcp-bastion" {
  name         = "gcp-bastion"
  machine_type = "${var.gcp_instance_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"

  boot_disk {
    initialize_params {
      image = "${var.gcp_disk_image}"
    }
  }

  metadata_startup_script = "${file("gcp_cloudconfig/vm_config.sh")}"
  
  network_interface {
    subnetwork = "${google_compute_subnetwork.public-subnet.name}"

    access_config {
      # Static IP
      nat_ip = "${google_compute_address.gcp-ip.address}"
    }
  }
}
resource "google_compute_instance" "velostrata-manager" {
  name         = "velostrata-manager"
  machine_type = "${var.gcp_instance_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"

  boot_disk {
    initialize_params {
      image = "projects/click-to-deploy-images/global/images/velostrata-mgmt-4-2-0-24912"
      size  = 60
    }
  }

  service_account {
    email  = "velos-manager-wpdemo@aws-gcp-migration-demo.iam.gserviceaccount.com"
    scopes = [ "https://www.googleapis.com/auth/cloud-platform", "rpc://phrixus.googleapis.com/auth/cloudrpc" ]
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.public-subnet.name}"

    access_config {
    }
  }

  metadata = {
    apiPassword              = "wpdemo1234"
    secretsEncKey            = "wpdemo1234"
    defaultServiceAccount    = "velos-cloud-extension-wpdemo@aws-gcp-migration-demo.iam.gserviceaccount.com"
    google-monitoring-enable = "1"
    google-logging-enable    = "1"
  }
}

resource "google_compute_instance" "gcp-private-vm" {
  name         = "gcp-private-vm"
  machine_type = "${var.gcp_instance_type}"
  zone         = "${data.google_compute_zones.available.names[1]}"

  boot_disk {
    initialize_params {
      image = "${var.gcp_disk_image}"
    }
  }

  metadata_startup_script = "${file("gcp_cloudconfig/vm_config.sh")}"

  network_interface {
    subnetwork = "${google_compute_subnetwork.private-subnet.name}"
  }
}
