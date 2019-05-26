output "gcp_bastion_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.gcp-vm.name}"
}

output "gcp_instance_internal_ip" {
  value = "${google_compute_instance.gcp-vm.network_interface.0.network_ip}"
}
