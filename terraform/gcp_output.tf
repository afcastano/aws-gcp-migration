output "gcp_bastion_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.gcp-bastion.name}"
}

output "gcp_private_vm_internal_ip" {
  value = "${google_compute_instance.gcp-private-vm.network_interface.0.network_ip}"
}
