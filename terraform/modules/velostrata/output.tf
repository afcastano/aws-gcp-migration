output "velostrata_aws_key" {
  value = "${aws_iam_access_key.velostrata-iam-key.id}"
}

output "velostrata_aws_secret" {
  value = "${aws_iam_access_key.velostrata-iam-key.secret}"
}

output "velostrata_manager_ip" {
  value = "${google_compute_instance.velostrata-manager.network_interface.0.access_config.0.nat_ip}"
}