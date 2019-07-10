resource "google_compute_address" "gcp-ip" {
  name        = "gcp-vm-ip-${var.region}"
  region      = "${var.region}"
}

resource "google_compute_instance" "gcp-bastion" {
  name         = "gcp-bastion"
  machine_type = "${var.instance_type}"
  zone         = "${var.zone}"
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = "${var.gcp_disk_image}"
    }
  }

  metadata_startup_script = "${file("./modules/gcp_target/gcp_cloudconfig/vm_config.sh")}"
  
  network_interface {
    subnetwork = "${google_compute_subnetwork.public-subnet.name}"

    access_config {
      # Static IP
      nat_ip = "${google_compute_address.gcp-ip.address}"
    }
  }
}