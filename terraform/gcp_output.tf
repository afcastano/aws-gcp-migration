output "gcp bastion public ip" {
  value = "${google_compute_instance.gcp-bastion.network_interface.0.access_config.0.nat_ip}"
}

output "gcp_private_vm_internal_ip" {
  value = "${google_compute_instance.gcp-private-vm.network_interface.0.network_ip}"
}

output "gcp velostrata manager ip" {
  value = "${google_compute_instance.velostrata-manager.network_interface.0.access_config.0.nat_ip}"
}
