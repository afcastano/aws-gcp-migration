output "vpc_name" {
    value = "${google_compute_network.demo-vpc.name}"
}

output "bastion_ip" {
    value = "${google_compute_instance.gcp-bastion.network_interface.0.access_config.0.nat_ip}"    
}

output "public_subnet_name" {
    value = "${google_compute_subnetwork.public-subnet.name}"
}

output "public_subnet_id" {
    value = "${google_compute_subnetwork.public-subnet.self_link}"
}

output "wp_subnet_id" {
    value = "${google_compute_subnetwork.private-subnet.self_link}"
}

output "lb_ip" {
    value = "${google_compute_global_forwarding_rule.wp-lb.ip_address}"
}

output "bastion_zone" {
    value = "${google_compute_instance.gcp-bastion.zone}"
}