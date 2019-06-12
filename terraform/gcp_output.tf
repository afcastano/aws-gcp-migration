output "gcp bastion public ip" {
  value = "${google_compute_instance.gcp-bastion.network_interface.0.access_config.0.nat_ip}"
}

output "gcp velostrata manager url" {
  value = "https://${google_compute_instance.velostrata-manager.network_interface.0.access_config.0.nat_ip}"
}

output "gcp velostrata workload service account" {
  value = "${google_service_account.velos-workload.email}"
}