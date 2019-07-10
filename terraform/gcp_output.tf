output "gcp bastion public ip" {
  value = "${module.gcp_target.bastion_ip}"
}

output "gcp velostrata manager url" {
  value = "https://${google_compute_instance.velostrata-manager.network_interface.0.access_config.0.nat_ip}"
}